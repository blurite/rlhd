/*
 * Copyright (c) 2018, Adam <Adam@sigterm.info>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#version 330

#include utils/constants.glsl

layout (location = 0) in ivec4 VertexPosition;
layout (location = 1) in vec4 uv;
layout (location = 2) in vec4 normal;

uniform mat4 lightProjectionMatrix;

out float alpha;
out vec2 fUv;
flat out int materialId;

void main()
{
    fUv = uv.yz;
    ivec3 vertex = VertexPosition.xyz;

    alpha = 1 - float(VertexPosition.w >> 24 & 0xff) / 255.;
    materialId = int(uv.x) >> 1;

    int terrainData = int(normal.w);
    int waterTypeIndex = terrainData >> 3 & 0x1F;
    bool isGroundPlane = (terrainData & 0xF) == 1; // isTerrain && plane == 0
    bool isTransparent = alpha < SHADOW_OPACITY_THRESHOLD;
    bool isWaterSurfaceOrUnderwaterTile = waterTypeIndex > 0;
    if (isGroundPlane || isTransparent || isWaterSurfaceOrUnderwaterTile)
        vertex *= 0;

    gl_Position = lightProjectionMatrix * vec4(vertex, 1.f);
}

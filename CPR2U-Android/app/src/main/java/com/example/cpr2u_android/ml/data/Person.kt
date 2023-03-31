/* Copyright 2021 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================
*/

package com.example.cpr2u_android.ml.data

import android.graphics.RectF

/**
 * 카메라 속 사람의 자세 데이터를 저장하는 클래스
 * @param keyPoints: 사람의 관절 포인트
 * @param boundingBox: 사람 전체를 둘러싸는 사각형 (Multipose 모델에서만 사용)
 * @param score: 인식 정확도
 */
data class Person(
    var id: Int = -1, // default id is -1
    val keyPoints: List<KeyPoint>,
    val boundingBox: RectF? = null, // Only MoveNet MultiPose return bounding box.
    val score: Float
)

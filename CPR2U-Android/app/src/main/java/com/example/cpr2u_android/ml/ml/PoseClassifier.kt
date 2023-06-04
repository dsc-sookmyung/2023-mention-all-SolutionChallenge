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

package com.example.cpr2u_android.ml.ml

import android.content.Context
import com.example.cpr2u_android.ml.data.Person
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.FileUtil

/**
 * PoseNet에서 추출한 데이터로 자세의 종류를 분류하는 클래스(현재 자세가 코브라 자세인지, 의자 자세인지, 전사 자세인지 등.. 건드릴 필요 없음)
 */
class PoseClassifier(
    private val interpreter: Interpreter,
    private val labels: List<String>,
) {
    private val input = interpreter.getInputTensor(0).shape()
    private val output = interpreter.getOutputTensor(0).shape()

    companion object {
        private const val MODEL_FILENAME = "pose_classifier.tflite"
        private const val LABELS_FILENAME = "pose_labels.txt"
        private const val CPU_NUM_THREADS = 4

        fun create(context: Context): PoseClassifier {
            val options = Interpreter.Options().apply {
                setNumThreads(CPU_NUM_THREADS)
            }
            return PoseClassifier(
                Interpreter(
                    FileUtil.loadMappedFile(
                        context,
                        MODEL_FILENAME,
                    ),
                    options,
                ),
                FileUtil.loadLabels(context, LABELS_FILENAME),
            )
        }
    }

    fun classify(person: Person?): List<Pair<String, Float>> {
        // Preprocess the pose estimation result to a flat array
        val inputVector = FloatArray(input[1])
        person?.keyPoints?.forEachIndexed { index, keyPoint ->
            // Log.e("keyPoint", "keyPoint.x : " + keyPoint.coordinate.x);
            // Log.e("keyPoint", "keyPoint.y : " + keyPoint.coordinate.y);
            inputVector[index * 3] = keyPoint.coordinate.y
            inputVector[index * 3 + 1] = keyPoint.coordinate.x
            inputVector[index * 3 + 2] = keyPoint.score
        }

        // Postprocess the model output to human readable class names
        val outputTensor = FloatArray(output[1])
        interpreter.run(arrayOf(inputVector), arrayOf(outputTensor))
        val output = mutableListOf<Pair<String, Float>>()
        outputTensor.forEachIndexed { index, score ->
            output.add(Pair(labels[index], score))
        }
        return output
    }

    fun close() {
        interpreter.close()
    }
}

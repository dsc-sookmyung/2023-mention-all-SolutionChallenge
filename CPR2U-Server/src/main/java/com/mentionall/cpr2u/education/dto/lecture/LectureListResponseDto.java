package com.mentionall.cpr2u.education.dto.lecture;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.util.List;

@Data
public class LectureListResponseDto {
    @Schema(example = "마지막으로 이수 완료한 강의 섹션(1~4)")
    @JsonProperty("current_step")
    private int currentStep;

    @JsonProperty("lecture_list")
    private List<LectureResponseDto> lectureList;

    public LectureListResponseDto(int currentStep, List<LectureResponseDto> lectureList) {
        this.currentStep = currentStep;
        this.lectureList = lectureList;
    }
}

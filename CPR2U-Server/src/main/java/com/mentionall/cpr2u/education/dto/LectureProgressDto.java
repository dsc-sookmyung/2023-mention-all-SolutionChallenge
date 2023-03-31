package com.mentionall.cpr2u.education.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.education.dto.lecture.LectureResponseDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.util.List;

@Data
public class LectureProgressDto {
    @Schema(example = "마지막으로 이수 완료한 강의 섹션(1~4)")
    @JsonProperty("current_step")
    private int currentStep;

    @JsonProperty("lecture_list")
    private List<LectureResponseDto> lectureList;

    public LectureProgressDto(EducationProgress progress, List<LectureResponseDto> lectureList) {
        this.currentStep = progress.getLastLecture().getStep();
        this.lectureList = lectureList;
    }
}

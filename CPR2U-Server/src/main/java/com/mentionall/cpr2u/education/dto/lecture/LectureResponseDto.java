package com.mentionall.cpr2u.education.dto.lecture;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.education.domain.Lecture;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LectureResponseDto {

    @Schema(example = "강의 ID")
    private Long id;

    @Schema(example = "강의 섹션(1~4)")
    private int step;

    @Schema(example = "강의 제목")
    private String title;

    @Schema(example = "강의 설명")
    private String description;

    @Schema(example = "강의 영상 URL")
    @JsonProperty("video_url")
    private String videoUrl;

    public LectureResponseDto(Lecture lecture) {
        this.id = lecture.getId();
        this.step = lecture.getStep();
        this.title = lecture.getTitle();
        this.description = lecture.getDescription();
        this.videoUrl = lecture.getVideoUrl();
    }
}

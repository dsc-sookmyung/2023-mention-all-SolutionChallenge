package com.mentionall.cpr2u.education.dto.lecture;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LectureRequestDto {
    @Schema(example = "강의 섹션(0~4)")
    private int step;

    @Schema(example = "강의 제목")
    private String title;

    @Schema(example = "강의 설명")
    private String description;

    @Schema(example = "강의 영상 URL")
    @JsonProperty("video_url")
    private String videoUrl;
}

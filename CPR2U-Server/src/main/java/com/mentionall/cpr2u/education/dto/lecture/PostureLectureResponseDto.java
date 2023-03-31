package com.mentionall.cpr2u.education.dto.lecture;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PostureLectureResponseDto {
    @Schema(example = "강의 영상 URL")
    @JsonProperty("video_url")
    String videoUrl;
}

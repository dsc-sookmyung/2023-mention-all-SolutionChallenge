package com.mentionall.cpr2u.education.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.user.domain.AngelStatusEnum;
import com.mentionall.cpr2u.user.domain.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Data
public class EducationProgressDto {
    @Schema(example = "사용자의 엔젤 상태(0: 수료 / 1: 만료 / 2: 미수료)")
    @JsonProperty("angel_status")
    private int angelStatus;

    @Schema(example = "사용자 닉네임")
    @JsonProperty
    private String nickname;

    @Schema(example = "사용자의 총 학습 완수율(0.0 ~ 1.0 사이 Double 값)")
    @JsonProperty("progress_percent")
    private double progressPercent;

    @Schema(example = "사용자의 완강 여부(0: 미완 / 2: 완료)")
    @JsonProperty("is_lecture_completed")
    private int isLectureCompleted;

    @Schema(example = "마지막으로 이수를 완료한 강의명(무시해주세요.)")
    @JsonProperty("last_lecture_title")
    private String lastLectureTitle;

    @Schema(example = "사용자의 퀴즈 완료 여부(0: 미완 / 2: 완료)")
    @JsonProperty("is_quiz_completed")
    private int isQuizCompleted;

    @Schema(example = "사용자의 자세 실습 완료 여부(0: 미완 / 2: 완료)")
    @JsonProperty("is_posture_completed")
    private int isPostureCompleted;

    @Schema(example = "만료까지 남은 일 수")
    @JsonProperty("days_left_until_expiration")
    private Integer daysLeftUntilExpiration;

    public EducationProgressDto(EducationProgress progress, User user) {
        this.angelStatus = user.getStatus().ordinal();
        this.nickname = user.getNickname();
        this.progressPercent = progress.getTotalProgress();
        this.lastLectureTitle = progress.getLastLecture().getTitle();
        this.isLectureCompleted = progress.getLectureProgressStatus().ordinal();
        this.isQuizCompleted = progress.getQuizProgressStatus().ordinal();
        this.isPostureCompleted = progress.getPostureProgressStatus().ordinal();
        if(this.angelStatus != AngelStatusEnum.UNACQUIRED.ordinal()) {
            int leftDays = 90 + (int)(ChronoUnit.DAYS.between(LocalDate.now(), user.getDateOfIssue().toLocalDate().atStartOfDay()));
            this.daysLeftUntilExpiration = leftDays >= 0 ? leftDays : null;
        }
        else this.daysLeftUntilExpiration = null;
    }
}

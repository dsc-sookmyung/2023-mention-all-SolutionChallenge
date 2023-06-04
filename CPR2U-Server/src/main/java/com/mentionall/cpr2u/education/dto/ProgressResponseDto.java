package com.mentionall.cpr2u.education.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.education.domain.progress.EducationProgress;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import static com.mentionall.cpr2u.education.domain.TestStandard.validTime;
import static com.mentionall.cpr2u.user.domain.AngelStatus.*;

@Data
public class ProgressResponseDto {
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

    @Schema(example = "사용자의 퀴즈 완료 여부(0: 미완 / 2: 완료)")
    @JsonProperty("is_quiz_completed")
    private int isQuizCompleted;

    @Schema(example = "사용자의 자세 실습 완료 여부(0: 미완 / 2: 완료)")
    @JsonProperty("is_posture_completed")
    private int isPostureCompleted;

    @Schema(example = "만료까지 남은 일 수")
    @JsonProperty("days_left_until_expiration")
    private Integer daysLeftUntilExpiration;

    public ProgressResponseDto(EducationProgress progress) {
        this.angelStatus = progress.getUser().getAngelStatus().ordinal();
        this.nickname = progress.getUser().getNickname();
        this.progressPercent = progress.getTotalProgress();

        this.isLectureCompleted = progress.getLectureProgress().getStatus().ordinal();
        this.isQuizCompleted = progress.getQuizProgress().getStatus().ordinal();
        this.isPostureCompleted = progress.getPostureProgress().getStatus().ordinal();

        if(progress.getUser().getAngelStatus() == UNACQUIRED) {
            this.daysLeftUntilExpiration = null;
        } else {
            LocalDate issuedAt = progress.getUser().getCertificate().getDateOfIssue().toLocalDate();
            long leftDays = validTime - (ChronoUnit.DAYS.between(issuedAt, LocalDate.now()));
            this.daysLeftUntilExpiration = leftDays >= 0 ? (int)leftDays : null;
        }
    }
}

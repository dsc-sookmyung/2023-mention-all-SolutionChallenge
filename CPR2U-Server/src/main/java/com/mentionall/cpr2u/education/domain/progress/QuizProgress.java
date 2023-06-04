package com.mentionall.cpr2u.education.domain.progress;

import com.mentionall.cpr2u.education.domain.ProgressStatus;
import com.mentionall.cpr2u.education.domain.TestStandard;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.Embeddable;

import static com.mentionall.cpr2u.education.domain.ProgressStatus.*;

@Embeddable
@Getter
@NoArgsConstructor
public class QuizProgress {
    private ProgressStatus status = NotCompleted;
    private int score = 0;

    public void updateScore(int score) {
        this.score = score;
        if (score >= TestStandard.quizScore) status = Completed;
    }
}

package com.mentionall.cpr2u.education.domain;

import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.util.Timestamped;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import javax.persistence.*;
import java.util.ArrayList;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class EducationProgress extends Timestamped {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lecture_id")
    private Lecture lastLecture = null;

    @Column
    private int quizScore = 0;

    @Column
    private int postureScore = 0;

    public EducationProgress(User user) {
        this.user = user;
    }

    public Lecture getLastLecture() {
        if (this.lastLecture == null)
            return new Lecture(0L, "", "", 0, "", new ArrayList());
        return this.lastLecture;
    }

    public double getTotalProgress() {
        int currentProgress = this.getLastLecture().getStep();
        if (this.quizScore >= TestStandard.quizScore) currentProgress++;
        if (this.postureScore >= TestStandard.postureScore) currentProgress++;

        return (double)currentProgress / (double)TestStandard.totalStep;
    }

    public ProgressStatus getLectureProgressStatus() {
        if (this.getLastLecture().getStep() == 0) return ProgressStatus.NotCompleted;
        if (this.getLastLecture().getStep() == TestStandard.finalLectureStep) return ProgressStatus.Completed;
        return ProgressStatus.InProgress;
    }

    public ProgressStatus getQuizProgressStatus() {
        if (this.quizScore >= TestStandard.quizScore) return ProgressStatus.Completed;
        return ProgressStatus.NotCompleted;
    }

    public ProgressStatus getPostureProgressStatus() {
        if (this.postureScore >= TestStandard.postureScore) return ProgressStatus.Completed;
        return ProgressStatus.NotCompleted;
    }

    public void updateQuizScore(int score) {
        this.quizScore = score;
    }

    public void updatePostureScore(int score) {
        this.postureScore = score;
    }

    public void updateLecture(Lecture lecture) {
        this.lastLecture = lecture;
    }
}

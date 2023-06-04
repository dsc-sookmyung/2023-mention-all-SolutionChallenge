package com.mentionall.cpr2u.education.domain.progress;

import com.mentionall.cpr2u.education.domain.TestStandard;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.util.Timestamped;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import javax.persistence.*;

import static com.mentionall.cpr2u.education.domain.ProgressStatus.*;

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

    @Embedded
    @AssociationOverride(name = "lastLecture", joinColumns = @JoinColumn(name = "last_lecture_id"))
    @AttributeOverrides({
            @AttributeOverride(name = "status", column = @Column(name = "lecture_status"))
    })
    private LectureProgress lectureProgress;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "status", column = @Column(name = "quiz_status")),
            @AttributeOverride(name = "score", column = @Column(name = "quiz_score"))
    })
    private QuizProgress quizProgress;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "status", column = @Column(name = "posture_status")),
            @AttributeOverride(name = "score", column = @Column(name = "posture_score"))
    })
    private PostureProgress postureProgress;

    public EducationProgress(User user) {
        this.user = user;
        this.lectureProgress = new LectureProgress();
        this.quizProgress = new QuizProgress();
        this.postureProgress = new PostureProgress();
    }

    public double getTotalProgress() {
        int currentProgress = this.lectureProgress.getLastStep();
        if (this.quizProgress.getStatus() == Completed) currentProgress++;
        if (this.postureProgress.getStatus() == Completed) currentProgress++;

        return (double)currentProgress / (double)TestStandard.totalStep;
    }

    public void reset() {
        this.lectureProgress = new LectureProgress();
        this.quizProgress = new QuizProgress();
        this.postureProgress = new PostureProgress();
    }
}

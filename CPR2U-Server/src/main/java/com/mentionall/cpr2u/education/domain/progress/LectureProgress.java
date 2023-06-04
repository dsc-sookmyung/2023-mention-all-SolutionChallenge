package com.mentionall.cpr2u.education.domain.progress;

import com.mentionall.cpr2u.education.domain.Lecture;
import com.mentionall.cpr2u.education.domain.ProgressStatus;
import com.mentionall.cpr2u.education.domain.TestStandard;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.Embeddable;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

import static com.mentionall.cpr2u.education.domain.ProgressStatus.Completed;
import static com.mentionall.cpr2u.education.domain.ProgressStatus.InProgress;

@Embeddable
@NoArgsConstructor
public class LectureProgress {
    private ProgressStatus status = ProgressStatus.NotCompleted;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "last_lecture_id")
    private Lecture lastLecture = null;

    public ProgressStatus getStatus() {
        return this.status;
    }

    public int getLastStep() {
        return (lastLecture == null) ? 0 : lastLecture.getStep();
    }

    public void updateLastLecture(Lecture lecture) {
        this.lastLecture = lecture;
        status = (lecture.getStep() >= TestStandard.finalLectureStep) ? Completed : InProgress;
    }
}

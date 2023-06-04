package com.mentionall.cpr2u.education.domain;

import com.mentionall.cpr2u.education.domain.progress.EducationProgress;
import com.mentionall.cpr2u.education.dto.lecture.LectureRequestDto;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Lecture implements Comparable<Lecture> {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 20)
    private String title;

    @Column(length = 255)
    private String videoUrl;

    @Column(unique = true)
    private int step;

    @Column(length = 50)
    private String description;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "lectureProgress.lastLecture")
    List<EducationProgress> progressList = new ArrayList();

    public Lecture(LectureRequestDto requestDto) {
        this.title = requestDto.getTitle();
        this.videoUrl = requestDto.getVideoUrl();
        this.step = requestDto.getStep();
        this.description = requestDto.getDescription();
    }

    @Override
    public int compareTo(Lecture other) {
        return this.step - other.step;
    }
}

package com.mentionall.cpr2u.education.controller;

import com.mentionall.cpr2u.education.dto.ProgressResponseDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureListResponseDto;
import com.mentionall.cpr2u.education.dto.ScoreRequestDto;
import com.mentionall.cpr2u.education.dto.quiz.QuizResponseDto;
import com.mentionall.cpr2u.education.service.EducationProgressService;
import com.mentionall.cpr2u.education.service.LectureService;
import com.mentionall.cpr2u.education.service.QuizService;
import com.mentionall.cpr2u.user.domain.PrincipalDetails;
import com.mentionall.cpr2u.user.service.UserService;
import com.mentionall.cpr2u.util.GetUserDetails;
import com.mentionall.cpr2u.util.ResponseDataTemplate;
import com.mentionall.cpr2u.util.ResponseTemplate;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_CERTIFICATED;
import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_SUCCESS;

@Tag(name = "EducationController", description = "학습 화면 컨트롤러")
@Slf4j
@RestController
@RequestMapping("/education")
@RequiredArgsConstructor
public class  EducationController {
    private final EducationProgressService progressService;
    private final LectureService lectureService;
    private final QuizService quizService;
    private final UserService userService;

    @Operation(summary = "유저의 학습 화면 정보 조회",
            description = "유저의 엔젤 자격과 현재 학습 진도 정보를 조회한다.\n" +
                    "angel_status : 사용자의 엔젤 상태(0: 수료 / 1: 만료 / 2: 미수료)\n" +
                    "progress_percent : 사용자의 총 학습 완수율(0.0 ~ 1.0 사이 Double 값)\n" +
                    "is_lecture_completed : 사용자의 완강 여부(0: 미완 / 2: 완료)\n" +
                    "is_quiz_completed : 사용자의 퀴즈 완료 여부(0: 미완 / 2: 완료)\n" +
                    "is_posture_completed : 사용자의 자세 실습 완료 여부(0: 미완 / 2: 완료)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ProgressResponseDto.class)))),
    })
    @GetMapping()
    public ResponseEntity<ResponseDataTemplate> getEducationInfo(@GetUserDetails PrincipalDetails userDetails) {

        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                progressService.readEducationInfo(userDetails.getUser()));
    }

    @Operation(summary = "유저의 강의 리스트 조회", description = "강의 리스트와 유저의 현재 강의 진도를 조회한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = LectureListResponseDto.class)))),
    })
    @GetMapping("/lectures")
    public ResponseEntity<ResponseDataTemplate> getLectureList(@GetUserDetails PrincipalDetails userDetails) {

        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                lectureService.readLectureProgressAndList(userDetails.getUser()));
    }

    @Operation(summary = "강의 수강 완료", description = "유저가 마지막으로 완료한 강의를 lectureId 값의 강의로 변경한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping("/lectures/progress/{lectureId}")
    public ResponseEntity<ResponseTemplate> completeLecture(
            @Parameter(description = "완강한 강의 ID") @PathVariable Long lectureId,
            @GetUserDetails PrincipalDetails userDetails) {
        progressService.completeLecture(userDetails.getUser(), lectureId);

        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }

    @Operation(summary = "퀴즈 질문 조회", description = "5개의 퀴즈 질문과 답변을 랜덤으로 조회한다.(리스트)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = QuizResponseDto.class)))),
    })
    @GetMapping("/quizzes")
    public ResponseEntity<ResponseDataTemplate> getQuizList() {
        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                quizService.readRandom5Quiz());
    }

    @Operation(summary = "퀴즈 테스트 완료", description = "유저의 퀴즈 테스트 결과를 저장한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "400", description = "이전 진도를 모두 완료해야 수강할 수 있습니다.",
                content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @PostMapping("/quizzes/progress")
    public ResponseEntity<ResponseTemplate> completeQuiz(
            @Parameter(description = "유저의 점수") @RequestBody ScoreRequestDto requestDto,
            @GetUserDetails PrincipalDetails userDetails) {
        progressService.completeQuiz(userDetails.getUser(), requestDto);
        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }

    @Operation(summary = "자세실습 테스트 완료", description = "유저가 자세실습 테스트를 통과했음을 저장한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "400", description = "이전 진도를 모두 완료해야 수강할 수 있습니다.",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @PostMapping("/exercises/progress")
    public ResponseEntity<ResponseTemplate> completePosture(
            @GetUserDetails PrincipalDetails userDetails,
            @Parameter(description = "유저의 점수") @RequestBody ScoreRequestDto requestDto) {
        progressService.completePosture(userDetails.getUser(), requestDto);
        userService.certificate(userDetails.getUser(), LocalDateTime.now());

        return ResponseTemplate.toResponseEntity(OK_CERTIFICATED);
    }


}

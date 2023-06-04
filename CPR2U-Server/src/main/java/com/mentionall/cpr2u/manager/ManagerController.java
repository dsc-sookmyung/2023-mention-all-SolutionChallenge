package com.mentionall.cpr2u.manager;

import com.mentionall.cpr2u.education.dto.quiz.QuizRequestDto;
import com.mentionall.cpr2u.education.service.QuizService;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.util.ResponseTemplate;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_SUCCESS;

@Slf4j
@RestController
@RequestMapping("/manage")
@RequiredArgsConstructor
@Hidden
public class ManagerController {

    private final QuizService quizService;
    private final AddressService addressService;

    @PostMapping("/quizzes")
    public ResponseEntity<ResponseTemplate> createQuiz(@RequestBody QuizRequestDto requestDto) {
        quizService.createQuiz(requestDto);
        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }

    @DeleteMapping("/quizzes")
    public ResponseEntity<ResponseTemplate> deleteQuiz(@RequestParam Long id) {
        quizService.deleteQuiz(id);
        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }

    @PostMapping("/addresses")
    public ResponseEntity<ResponseTemplate> loadAllAddresses() {
        addressService.loadAddressList();
        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }
}

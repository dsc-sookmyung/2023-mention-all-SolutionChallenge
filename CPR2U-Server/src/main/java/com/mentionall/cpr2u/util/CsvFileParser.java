package com.mentionall.cpr2u.util;

import com.mentionall.cpr2u.util.exception.CustomException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.mentionall.cpr2u.util.exception.ResponseCode.SERVER_ERROR_PARSING_FAILED;

@Slf4j
@Component
public class CsvFileParser {

    public List<List<String>> parse(URI uri) {
        log.info("Parsing " + uri.getPath() + "...");

        try {
            List<List<String>> response = new ArrayList<>();
            BufferedReader br = Files.newBufferedReader(Paths.get(uri));

            String line = "";
            while ((line = br.readLine()) != null) {
                String[] words = line.split(",");
                response.add(Arrays.asList(words));
            }

            return response;
        } catch (IOException e) {
            e.printStackTrace();
            throw new CustomException(SERVER_ERROR_PARSING_FAILED);
        }
    }

}

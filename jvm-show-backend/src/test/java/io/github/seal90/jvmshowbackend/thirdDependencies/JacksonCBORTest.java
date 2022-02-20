package io.github.seal90.jvmshowbackend.thirdDependencies;

import com.fasterxml.jackson.core.io.UTF8Writer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.cbor.CBORFactory;
import lombok.SneakyThrows;
import org.junit.jupiter.api.Test;
import org.springframework.http.codec.cbor.Jackson2CborDecoder;
import org.springframework.http.codec.cbor.Jackson2CborEncoder;
import org.springframework.messaging.rsocket.RSocketStrategies;
import org.springframework.util.MimeType;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class JacksonCBORTest {

    public void encodeTest() {
        RSocketStrategies.builder()
                .encoders(encoders -> encoders.add(new Jackson2CborEncoder()))
                .decoders(decoders -> decoders.add(new Jackson2CborDecoder()))
//                .metadataExtractorRegistry(metadataExtractorRegistry -> {
//                    metadataExtractorRegistry.metadataToExtract(MimeType.valueOf(Constants.MIME_FILE_EXTENSION), String.class, Constants.FILE_EXTN);
//                    metadataExtractorRegistry.metadataToExtract(MimeType.valueOf(Constants.MIME_FILE_NAME), String.class, Constants.FILE_NAME);
//                })
                .build();
    }

    @SneakyThrows
    @Test
    public void decodeListTest() {
        byte[] value = new byte[]{25, (byte)168, 0};

        CBORFactory cborFactory = new CBORFactory();
        ObjectMapper mapper = new ObjectMapper(cborFactory);

        Integer v = mapper.readValue(value, Integer.class);
        System.out.println(v);

        byte[] wb = mapper.writeValueAsBytes(43008);
        System.out.println(Arrays.toString(wb));
    }
}

package io.github.seal90.jvmshowbackend.thirdDependencies;

import org.springframework.http.codec.cbor.Jackson2CborDecoder;
import org.springframework.http.codec.cbor.Jackson2CborEncoder;
import org.springframework.messaging.rsocket.RSocketStrategies;
import org.springframework.util.MimeType;

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
}

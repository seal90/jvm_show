package io.github.seal90.jvmshowbackend.rsocket;

import org.junit.jupiter.api.Test;
import org.springframework.http.codec.cbor.Jackson2CborDecoder;
import org.springframework.http.codec.cbor.Jackson2CborEncoder;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.messaging.rsocket.RSocketStrategies;

public class SpringRSocketTest {

    // https://docs.spring.io/spring-framework/docs/current/reference/pdf/rsocket.pdf

    @Test
    public void serverTest() {
        RSocketStrategies strategies = RSocketStrategies.builder()
                .encoders(encoders -> encoders.add(new Jackson2CborEncoder()))
                .decoders(decoders -> decoders.add(new Jackson2CborDecoder()))
                .build();
        RSocketRequester requester = RSocketRequester.builder()
                .rsocketStrategies(strategies)
                .tcp("localhost", 7000);
    }

    @Test
    public void clientTest() {
        RSocketRequester requester = RSocketRequester.builder().tcp("localhost", 7000);
    }
}

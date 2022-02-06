package io.github.seal90.jvmshowbackend.rsocket;

import io.netty.buffer.ByteBuf;
import io.rsocket.ConnectionSetupPayload;
import io.rsocket.Payload;
import io.rsocket.RSocket;
import io.rsocket.SocketAcceptor;
import io.rsocket.core.DefaultConnectionSetupPayload;
import io.rsocket.core.RSocketConnector;
import io.rsocket.core.RSocketServer;
import io.rsocket.frame.FrameType;
import io.rsocket.frame.SetupFrameCodec;
import io.rsocket.transport.netty.client.TcpClientTransport;
import io.rsocket.transport.netty.server.TcpServerTransport;
import io.rsocket.util.DefaultPayload;
import org.junit.jupiter.api.Test;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

public class RSocketTest {

    @Test
    public void serverTest() {
		RSocketServer.create(new SocketAcceptor() {
			@Override
			public Mono<RSocket> accept(ConnectionSetupPayload connectionSetupPayload, RSocket rSocket) {
				System.out.println(connectionSetupPayload.dataMimeType());
				return Mono.just(new RSocket() {
					@Override
					public Mono<Payload> requestResponse(Payload payload) {
						return RSocket.super.requestResponse(payload);
					}
				});
			}
		}).bind(TcpServerTransport.create(7000)).block().onClose();

		try {
			Thread.sleep(1000000L);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
    }

    @Test
    public void clientTest() {
//
//		SetupFrameCodec.encode()
//		ByteBuf setupFrame =
//		ConnectionSetupPayload connectionSetupPayload = new DefaultConnectionSetupPayload(setupFrame);
//
//		Mono<RSocket> client = RSocketConnector.create().setupPayload(connectionSetupPayload)
//				.connect(TcpClientTransport.create(7000));
//
//		Payload payload = DefaultPayload.create("hello world");
//		Mono<Payload> response = client.block().requestResponse(payload);
//
//		StepVerifier.create(response).verifyComplete();
    }
}

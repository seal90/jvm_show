package io.github.seal90.jvmshowbackend.rsocket;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufAllocator;
import io.netty.buffer.Unpooled;
import io.netty.channel.unix.DomainSocketAddress;
import io.rsocket.ConnectionSetupPayload;
import io.rsocket.Payload;
import io.rsocket.RSocket;
import io.rsocket.SocketAcceptor;
import io.rsocket.core.DefaultConnectionSetupPayload;
import io.rsocket.core.RSocketConnector;
import io.rsocket.core.RSocketServer;
import io.rsocket.frame.FrameHeaderCodec;
import io.rsocket.frame.FrameType;
import io.rsocket.frame.SetupFrameCodec;
import io.rsocket.transport.netty.client.TcpClientTransport;
import io.rsocket.transport.netty.server.TcpServerTransport;
import io.rsocket.util.DefaultPayload;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.buffer.DataBufferFactory;
import org.springframework.core.io.buffer.NettyDataBufferFactory;
import reactor.core.publisher.Mono;
import reactor.netty.tcp.TcpClient;
import reactor.netty.tcp.TcpServer;
import reactor.test.StepVerifier;

public class RSocketTest {

    @Test
    public void serverTest() {
    	TcpServer domainServer = TcpServer.create().bindAddress(() -> new DomainSocketAddress("/tmp/test.socket"));

		RSocketServer.create(new SocketAcceptor() {
			@Override
			public Mono<RSocket> accept(ConnectionSetupPayload connectionSetupPayload, RSocket rSocket) {
				System.out.println(connectionSetupPayload.dataMimeType());
				return Mono.just(new RSocket() {
					@Override
					public Mono<Payload> requestResponse(Payload payload) {
						return Mono.just(payload);
					}
				});
			}
		}).bind(TcpServerTransport.create(domainServer)).block().onClose();

		try {
			Thread.sleep(1000000L);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
    }

    @Test
    public void clientTest() {
		TcpClient domainClient = TcpClient.create().remoteAddress(() -> new DomainSocketAddress("/tmp/test.socket"));
////		SetupFrameCodec.encode()
//		ByteBuf setupFrame = Unpooled.directBuffer();
//		FrameHeaderCodec.ensureFrameType();
//		ConnectionSetupPayload connectionSetupPayload = new DefaultConnectionSetupPayload(setupFrame);

		Mono<RSocket> client = RSocketConnector.create()
				.connect(TcpClientTransport.create(domainClient));

		Payload payload = DefaultPayload.create("hello world");
		Mono<Payload> response = client.block().requestResponse(payload);
//		Payload responsePayload = response.block();
//		System.out.println(responsePayload.getDataUtf8().equals("hello world"));
		StepVerifier
				.create(response).expectNextMatches(p -> p.getDataUtf8().equals("hello world")).verifyComplete();
    }

}

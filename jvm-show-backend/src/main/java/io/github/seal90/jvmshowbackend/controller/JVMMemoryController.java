package io.github.seal90.jvmshowbackend.controller;

import io.github.seal90.jvmshowbackend.service.JVMMemoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.rsocket.RSocketRequester;
import org.springframework.messaging.rsocket.RSocketStrategies;
import org.springframework.messaging.rsocket.annotation.ConnectMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Mono;

import javax.annotation.PreDestroy;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Controller
public class JVMMemoryController {

    @Autowired
    private JVMMemoryService jvmMemoryService;

    @Autowired
    RSocketStrategies strategies;

    private final List<RSocketRequester> CLIENTS = new ArrayList<>();

    @MessageMapping("memory.heap.apply")
    public Mono<Integer> applyHeapByte(Integer byteSize) {
        Integer heapMemoryBytesNum = jvmMemoryService.applyHeapByte(byteSize);
        return Mono.just(heapMemoryBytesNum);
    }

    @MessageMapping("memory.heap.free")
    public Mono freeHeapByte() {
        jvmMemoryService.freeHeapByte();
        return Mono.empty();
    }

    @MessageMapping("memory.heap.clear")
    public Mono clearHeapByte() {
        jvmMemoryService.clearHeapByte();
        return Mono.empty();
    }

    @MessageMapping("memory.vm.gc")
    public Mono<Boolean> gcVM() {
        jvmMemoryService.gcVM();
        return Mono.just(true);
    }

    @MessageMapping("memory.heapByteBuffer.apply")
    public Mono<Integer> applyHeapByteBuffer(Integer byteSize) {
        Integer nums = jvmMemoryService.applyHeapByteBuffer(byteSize);
        return Mono.just(nums);
    }

    @MessageMapping("memory.heapByteBuffer.free")
    public Mono freeHeapByteBuffer(){
        jvmMemoryService.freeHeapByteBuffer();
        return Mono.empty();
    }

    @MessageMapping("memory.heapByteBuffer.clear")
    public Mono clearHeapByteBuffer() {
        jvmMemoryService.clearHeapByteBuffer();
        return Mono.empty();
    }

    @MessageMapping("memory.direct.apply")
    public Mono<Integer> applyDirectByte(Integer byteSize) {
        Integer num = jvmMemoryService.applyDirectByteBuffer(byteSize);
        return Mono.just(num);
    }

    @MessageMapping("memory.direct.free")
    public Mono freeDirectByte() {
        jvmMemoryService.freeDirectByteBuffer();
        return Mono.empty();
    }

    @MessageMapping("memory.direct.clear")
    public Mono clearDirectByte() {
        jvmMemoryService.clearDirectByteBuffer();
        return Mono.empty();
    }

    @MessageMapping("memory.metaspace.apply")
    public Mono<Integer> applyMetaspace(Integer num) {
        Integer clazzNameNum = jvmMemoryService.applyMetaspaceByte(num);
        return Mono.just(clazzNameNum);
    }

    @ConnectMapping("connect")
    public void connect(RSocketRequester requester,
                        @Payload String client) {

        requester.rsocket()
                .onClose()
                .doFirst(() -> {
                    // Add all new clients to a client list
                    log.info("Client: {} CONNECTED.", client);
                    CLIENTS.add(requester);
                })
                .doOnError(error -> {
                    // Warn when channels are closed by clients
                    log.warn("Channel to client {} CLOSED", client);
                })
                .doFinally(consumer -> {
                    // Remove disconnected clients from the client list
                    CLIENTS.remove(requester);
                    log.info("Client {} DISCONNECTED", client);
                })
                .subscribe();
    }

    @PreDestroy
    public void destroy() {
        CLIENTS.stream().forEach(requester -> requester.rsocket().dispose());
    }

}

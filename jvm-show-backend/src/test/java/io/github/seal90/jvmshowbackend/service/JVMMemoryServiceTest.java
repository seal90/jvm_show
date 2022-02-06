package io.github.seal90.jvmshowbackend.service;

import lombok.SneakyThrows;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@ExtendWith(SpringExtension.class)
public class JVMMemoryServiceTest {

    @InjectMocks
    private JVMMemoryService jvmMemoryService;

    /**
     * -Xmx512m
     */
    @SneakyThrows
    @Test
    public void applyHeapByteTest() {
        while (true) {
            jvmMemoryService.applyHeapByte(2048000);
            Thread.sleep(200);
        }
    }

    /**
     * -Xmx512m
     */
    @SneakyThrows
    @Test
    public void applyHeapByteBufferTest() {
        while (true) {
            jvmMemoryService.applyHeapByteBuffer(204800);
            Thread.sleep(50);
        }
    }

    /**
     * -XX:MaxDirectMemorySize=256m
     */
    @SneakyThrows
    @Test
    public void applyDirectByteBufferTest() {
        while (true) {
            jvmMemoryService.applyDirectByteBuffer(204800);
            Thread.sleep(50);
        }
    }

    /**
     * -XX:MaxMetaspaceSize=200m
     */
    @SneakyThrows
    @Test
    public void applyMetaspaceByteTest() {
        while (true) {
            jvmMemoryService.applyMetaspaceByte(10000);
            Thread.sleep(50);
        }
    }
}

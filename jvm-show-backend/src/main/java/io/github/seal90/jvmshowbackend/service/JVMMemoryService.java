package io.github.seal90.jvmshowbackend.service;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.buffer.Unpooled;
import org.springframework.stereotype.Service;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

@Service
public class JVMMemoryService {

    private List<byte[]> heapMemoryBytes = new ArrayList<>();

    private List<ByteBuffer> directByteBuffers = new ArrayList<>();

    private List<ByteBuffer> heapByteBuffers = new ArrayList<>();

    private byte[] compiledClazz = null;

    private Long clazzNameNum = 0L;

    private Long holdClassNameNum = 0L;

    private List<Class> holdClass = new ArrayList<>();

    /**
     * allocate heap memory
     * @param byteSize
     */
    public Integer applyHeapByte(Integer byteSize) {
        byte[] bytes = new byte[byteSize];
        heapMemoryBytes.add(bytes);
        return heapMemoryBytes.size();
    }

    /**
     * Free heap memory by reassignment
     */
    public void freeHeapByte() {
        heapMemoryBytes = new ArrayList<>();
    }

    /**
     * Free heap memory by call clear method
     */
    public void clearHeapByte() {
        heapMemoryBytes.clear();
    }

    /**
     * call gc
     */
    public void gcVM() {
        System.gc();
    }

    /**
     * allocate heap memory
     * @param byteSize
     */
    public Integer applyHeapByteBuffer(Integer byteSize) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(byteSize);
        heapByteBuffers.add(byteBuffer);
        return heapByteBuffers.size();
    }

    /**
     * Free heap memory by reassignment
     */
    public void freeHeapByteBuffer() {
        heapByteBuffers = new ArrayList<>();
    }

    /**
     * Free heap memory by call clear method
     */
    public void clearHeapByteBuffer() {
        heapByteBuffers.clear();
    }

    /**
     * allocate direct memory
     * @param byteSize
     */
    public Integer applyDirectByteBuffer(Integer byteSize) {
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(byteSize);
        directByteBuffers.add(byteBuffer);
        return directByteBuffers.size();
    }

    /**
     * Free direct memory by reassignment
     */
    public void freeDirectByteBuffer() {
        directByteBuffers = new ArrayList<>();
    }

    /**
     * call clear method clear direct memory
     */
    public void clearDirectByteBuffer() {
        directByteBuffers.clear();
    }

    /**
     * netty allow memory
     */
//    public void nettyByteBuffer() {
//        ByteBuf byteBuf = Unpooled.buffer();
//        Unpooled.directBuffer();
//        PooledByteBufAllocator pooledByteBufAllocator = new PooledByteBufAllocator();
//        pooledByteBufAllocator.buffer();
//        pooledByteBufAllocator.directBuffer();
//    }

    /**
     * allocate metaspace memory hold class
     */
    public Long applyMetaspaceByteHold(Integer num) {
        if(null == compiledClazz) {
            String clazzBase64 = "yv66vgAAADcADAEAEm15cGFja2FnZS9NeWNsYXNzMAcAAQEAEGphdmEvbGFuZy9PYmplY3QHAAMBAApTb3VyY2VGaWxlAQANTXljbGFzczAuamF2YQEABjxpbml0PgEAAygpVgwABwAICgAEAAkBAARDb2RlACEAAgAEAAAAAAABAAEABwAIAAEACwAAABEAAQABAAAABSq3AAqxAAAAAAABAAUAAAACAAY=";

            compiledClazz = Base64.getDecoder().decode(clazzBase64);
            compiledClazz[7] = 52;
        }
        int classNameLength = Integer.valueOf(compiledClazz[12]);

        MyClassLoader myClassLoader = new MyClassLoader(Thread.currentThread().getContextClassLoader());

        for (int i = 0; i < num; i++) {
            Long currentNum = holdClassNameNum++;
            byte[] bytes = String.valueOf(currentNum).getBytes();
            byte[] bytecode = new byte[compiledClazz.length + bytes.length - 1];
            System.arraycopy(compiledClazz, 0, bytecode, 0, 30);
            bytecode[12] = (byte) (classNameLength + bytes.length - 1 & 0xFF);

            System.arraycopy(bytes, 0, bytecode, 30, bytes.length);
            System.arraycopy(compiledClazz, 31, bytecode, 30 + bytes.length, compiledClazz.length - 31);

            String classname = "mypackage.Myclass" + currentNum;
            Class cl = myClassLoader.defineClass(classname, bytecode);
            holdClass.add(cl);
        }
        return holdClassNameNum;
    }

    public void clearMetaspaceHoldClass() {
        holdClass.clear();
    }

    /**
     * allocate metaspace memory
     */
    public Long applyMetaspaceByte(Integer num) {
        if(null == compiledClazz) {
            String clazzBase64 = "yv66vgAAADcADAEAEm15cGFja2FnZS9NeWNsYXNzMAcAAQEAEGphdmEvbGFuZy9PYmplY3QHAAMBAApTb3VyY2VGaWxlAQANTXljbGFzczAuamF2YQEABjxpbml0PgEAAygpVgwABwAICgAEAAkBAARDb2RlACEAAgAEAAAAAAABAAEABwAIAAEACwAAABEAAQABAAAABSq3AAqxAAAAAAABAAUAAAACAAY=";

            compiledClazz = Base64.getDecoder().decode(clazzBase64);
            compiledClazz[7] = 52;
        }
        int classNameLength = Integer.valueOf(compiledClazz[12]);

        MyClassLoader myClassLoader = new MyClassLoader(Thread.currentThread().getContextClassLoader());

        for (int i = 0; i < num; i++) {
            Long currentNum = clazzNameNum++;
            byte[] bytes = String.valueOf(currentNum).getBytes();
            byte[] bytecode = new byte[compiledClazz.length + bytes.length - 1];
            System.arraycopy(compiledClazz, 0, bytecode, 0, 30);
            bytecode[12] = (byte) (classNameLength + bytes.length - 1 & 0xFF);

            System.arraycopy(bytes, 0, bytecode, 30, bytes.length);
            System.arraycopy(compiledClazz, 31, bytecode, 30 + bytes.length, compiledClazz.length - 31);

            String classname = "mypackage.Myclass" + currentNum;
            Class cl = myClassLoader.defineClass(classname, bytecode);
        }
        return clazzNameNum;
    }

    public static class MyClassLoader extends ClassLoader {
        public MyClassLoader(ClassLoader parent) {
            super(parent);
        }

        public Class<?> defineClass(String name, byte[] code) {
            return defineClass(name, code, 0, code.length);
        }
    }
}

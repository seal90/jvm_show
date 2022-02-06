package io.github.seal90.jvmshowbackend.classCode;

import lombok.SneakyThrows;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.io.InputStream;
import java.util.Arrays;
import java.util.Base64;

public class ClassByteLoadClassTest {

    // https://docs.oracle.com/javase/specs/jvms/se15/html/jvms-4.html
    @Test
    public void loadClass() {

        String clazzBase64 ="yv66vgAAADcADAEAEm15cGFja2FnZS9NeWNsYXNzMAcAAQEAEGphdmEvbGFuZy9PYmplY3QHAAMBAApTb3VyY2VGaWxlAQANTXljbGFzczAuamF2YQEABjxpbml0PgEAAygpVgwABwAICgAEAAkBAARDb2RlACEAAgAEAAAAAAABAAEABwAIAAEACwAAABEAAQABAAAABSq3AAqxAAAAAAABAAUAAAACAAY=";

        byte[] compiledClazz = Base64.getDecoder().decode(clazzBase64);
        compiledClazz[7] = 52;
        int classNameLength = Integer.valueOf(compiledClazz[12]);

        MyClassLoader myClassLoader = new MyClassLoader(Thread.currentThread().getContextClassLoader());

        for (int i = 0; ; i++) {
            byte[] bytes = String.valueOf(i).getBytes();
            byte[] bytecode = new byte[compiledClazz.length + bytes.length - 1];
            System.arraycopy(compiledClazz, 0, bytecode, 0, 30);
            bytecode[12] = (byte) (classNameLength + bytes.length - 1 & 0xFF);

            System.arraycopy(bytes, 0, bytecode, 30, bytes.length);
            System.arraycopy(compiledClazz, 31, bytecode, 30 + bytes.length, compiledClazz.length - 31);

            String classname = "mypackage.Myclass" + i;
            Class c = myClassLoader.getClass(classname, bytecode);
        }
    }

    public static class MyClassLoader extends ClassLoader {
        public MyClassLoader(ClassLoader parent) {
            super(parent);
        }

        public Class<?> getClass(String name, byte[] code) {
            return defineClass(name, code, 0, code.length);
        }
    }

    @Test
    @SneakyThrows
    public void loadFromFile() {
        ClassPathResource resource = new ClassPathResource("io/github/seal90/jvmmemoryshow/config/RSocketConfig.class");
        InputStream inputStream = resource.getInputStream();
        byte[] allFile = new byte[10240];
        inputStream.read(allFile);
        inputStream.close();
        byte[] magicNumBytes = Arrays.copyOfRange(allFile, 0, 4);
        byte[] minorVersionBytes = Arrays.copyOfRange(allFile, 4, 6);
        byte[] majorVersionBytes = Arrays.copyOfRange(allFile, 6, 8);
        byte[] constantPoolCountBytes = Arrays.copyOfRange(allFile, 8, 10);



        byte[] cpInfoBytes = Arrays.copyOfRange(allFile, 10, 11);

        Integer magicNum = bytesToInt(magicNumBytes, 0);
        Short minorVersion = bytesToShort(minorVersionBytes);
        Short majorVersion = bytesToShort(majorVersionBytes);
        Short constantPoolCount = bytesToShort(constantPoolCountBytes);
        byte cpInfo = cpInfoBytes[0];

        int readFrom = 10;
        for (int i=0;i<cpInfo;i++) {
            byte tag = allFile[readFrom];

            switch (tag) {
                case 10: readFrom += 5; break;
                case 7:
                    readFrom += 1;
                    byte[] nameIndexBytes = Arrays.copyOfRange(allFile, readFrom, readFrom+2);
                    Short nameIndex = bytesToShort(constantPoolCountBytes);
                    System.out.println(readFrom);
            }

        }

        System.out.println(Integer.toHexString(magicNum)+":"+minorVersion+":"+majorVersion+":"+constantPoolCount);
        System.out.println(Arrays.toString(allFile));
    }

    public static int bytesToInt(byte[] src, int offset) {
        int value;
        value = (int) ((src[offset+3] & 0xFF)
                | ((src[offset+2] & 0xFF)<<8)
                | ((src[offset+1] & 0xFF)<<16)
                | ((src[offset] & 0xFF)<<24));
        return value;
    }

    public static short bytesToShort(byte[] src) {
        short value;
        value = (short) ((src[1] & 0xFF)
                | ((src[0] & 0xFF)<<8));
        return value;
    }
}

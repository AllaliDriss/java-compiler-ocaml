package tutu.titi.toto;

public class Compile {
    public int nombre = 0;
}

public class C {}

public class D extends C {}

public class B {

    private int age;
    private C petitd = new D();

    B() {
        age = 5;
    }
    public B(int bint) {
        age = bint;
    }

    public void testHeritage() {
      D d = new D();
      petitd = d;
      C c = new D();
      C cc = null;
      cc = new D();
      c = d;
    }

    public String b = "coucou";

    public String method() {
        return "result";
    }

    public String method(int a) {
      return "coucou";
    }

    public String test() {
      Compile c = new Compile();
      int nb = c.nombre + 2;
      String a = null;
      c = null;
      return method();
    }

    public String test2() {
      return method(2);
    }
}

public class A {

    int a1 = 1;
    int[] a = { 3,4,5 };
    boolean a2 = false;
    String a6 = "jsdjkndjk\njdsdjkf";

    private String method() {
        B b = new B();
        B bage = new B(20);
        return "b.b";
    }

    public void params(String toto, int tutu) {
        tutu++;

        for (int i = 0; i < tutu; i++) {
            String astr = "Compilo";
            i += 5;
        }

        try {
            method();
        } catch (RuntimeException r) {
            r;
            String c1 = "catch 1";
        } catch (B b) {
            String c2 = b.method(20);
        } finally {
            float t = .1;
            t *= 5.;
        }
		
    }

    int test() {

        4 = 3;
        43.0 = (float)43;

        int[] myIntArray = new int[3];
        int[] myArray = {1,2,a1};
        int[] myInt = new int[]{1,2,3};
        float[] a = { 1.2, 2.3, 3.4 };
        String[] str = { "str", method() };

        4++;
        --27.;

        int c = (3 + 3);
        if (c >= 10) {
          (true? c: 2);
        }

        String call = method();
        throw 45=3;

        if (43==3) {
          int d = 3;
            d++;
        } else {
            43--;
            c--;
        }

        while(true) {
            43++;
        }

        return 34;
    }

}


public class MyException {

}

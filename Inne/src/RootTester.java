public class RootTester {

    public static double mySqrt(double value){
        double result=(value+1)/2;

        for(int i=0; i<9; i++)
            result=result/2+value/(2*result);

        return result;
    }

    public static void main(String[] args){

        System.out.println(mySqrt(27));
        System.out.println(Math.sqrt(27));

    }

}

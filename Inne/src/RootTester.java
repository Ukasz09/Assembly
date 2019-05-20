public class RootTester {

    public static double mySqrt(double value){
        double result=(value+1)/2;

        for(int i=0; i<9; i++)
            result=result/2+value/(2*result);

        return result;
    }

    public static double mySqrt2(double value, double n){

        double x=value;
        double tmpX;

        for(int i=0; i<10; i++){
            tmpX=x;
            x=(1/n)*((n-1)*tmpX+value/(Math.pow(tmpX,(n-1))));
        }

        return x;
    }

    public static void main(String[] args){

        System.out.println(mySqrt2(64,3));

    }

}

package example.r2chill.Activities;

import example.r2chill.R;

public class ColorPickerActivity extends DatabaseActivity {

    protected int[] colorArray;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        colorArray = {R.color.red, R.color.pink, R.color.purple, R.color.deep_purple,
                    R.color.indigo, R.color.blue, R.color.light_blue, R.color.cyan, R.color.teal,
                    R.color.green, R.color.light_green, R.color.lime, R.color.yellow,
                    R.color.amber, R.color.orange, R.color.deep_orange, R.color.brown,
                    R.color.grey, R.color.blue_grey, R.color.white};
        for (int i=0; i < colorArray.length ; i++) {
            colorArray[i] = getResources().getColor(colorArray[i]);
        }
    }
}

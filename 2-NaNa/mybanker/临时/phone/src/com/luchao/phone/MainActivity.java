package com.luchao.phone;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

public class MainActivity extends Activity {

	private EditText haoma;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Button call=(Button)findViewById(R.id.call);
        haoma=(EditText)findViewById(R.id.haoma);
        call.setOnClickListener(new ButtonOnClickListener());
    }

    private final class ButtonOnClickListener implements OnClickListener{
		@Override
		public void onClick(View v) {
			String str=haoma.getText().toString();
			Intent intent = new Intent();
			intent.setAction("android.intent.action.CALL");
//			intent.addCategory("");
			intent.setData(Uri.parse("tel:"+ str));
			startActivity(intent);
		}
    	
    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_main, menu);
        return true;
    }
}

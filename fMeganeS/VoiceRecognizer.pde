/*
 //-- References 参考文献 --//
 http://d.hatena.ne.jp/language_and_engineering/20121022/p1
 http://d.hatena.ne.jp/language_and_engineering/20121107/AndroidTTSAndSpeechRecognitionDSL
 http://developer.android.com/reference/android/speech/RecognitionListener.html
 //-- References 参考文献 --//
 */

/*-- Libraries ライブラリ群 --*/
import java.util.Locale;
import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
/*-- Libraries ライブラリ群 --*/

class VoiceRecognizer {

  SpeechRecognizer sr; // Object for recognizing speech
  Intent intent;
  ArrayList<String> candidates; // Candidates of recognized
  String result; // first candidate
  int mode = 0;

  VoiceRecognizer() {
    sr = SpeechRecognizer.createSpeechRecognizer(getApplicationContext()); // Create speech recognizer
    // RecognitionListener
    /* Reference : http://developer.android.com/reference/android/speech/RecognitionListener.html */
    sr.setRecognitionListener(new RecognitionListener() {
      @Override public void onBeginningOfSpeech() {
      }
      @Override public void onBufferReceived(byte[] buffer) {
      }
      @Override public void onEndOfSpeech() {
      }
      @Override public void onEvent(int eventType, Bundle params) {
      }
      @Override public void onPartialResults(Bundle partialResults) {
      }
      @Override public void onRmsChanged(float rmsdB) {
      }

      @Override public void onError(int error) {
        println("error: " + error);
        mode = (-1)*error;
        /* List of error code */
        /* http://developer.android.com/intl/ja/reference/android/speech/SpeechRecognizer.html#ERROR_AUDIO */
      }

      @Override public void onReadyForSpeech(Bundle params) {
        println("Start Recognizing"); // Notify of start recognizing
        mode = 1;
      }

      @Override public void onResults(Bundle results) {
        candidates = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION); // Get results
        result = candidates.get(0); // Get result of first candidate
        mode = 0;
        
        println("get!");
      }
    }
    ); // Set Listener

    intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH); // Ceate intent for recognizing speech
    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM); // Use a language model based on free-form speech recognition
  }

  void startRecognize() {
    // Set recognizeing language
    //intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.US.toString());
    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.JAPAN.toString());

    sr.startListening(intent); // Start listening
  }
}


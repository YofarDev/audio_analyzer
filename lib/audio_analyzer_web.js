function getAmplitudes(audioUrl, samplesPerSecond, onSuccess, onError) {
  console.log(audioUrl);
 const audioContext = new (window.AudioContext || window.webkitAudioContext)();
 fetch(audioUrl)
  .then(response => response.arrayBuffer())
  .then(arrayBuffer => audioContext.decodeAudioData(arrayBuffer))
  .then(audioBuffer => {
 const channelData = audioBuffer.getChannelData(0);
 const sampleRate = audioBuffer.sampleRate;
 const windowSize = Math.floor(sampleRate / samplesPerSecond);
 const amplitudes = [];
 for (let i = 0; i < channelData.length; i += windowSize) {
 const slice = channelData.slice(i, i + windowSize);
 const rms = Math.sqrt(slice.reduce((sum, x) => sum + x * x, 0) / slice.length);
 amplitudes.push(rms);
  }
 onSuccess(amplitudes);
  })
  .catch(error => onError(error.message));
  }
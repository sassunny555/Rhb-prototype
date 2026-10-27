// OCR runs locally in a browser worker. Only library/model downloads use the network.
let bankingOcrWorker;
window.bankingCaptureFrame = () => {
  function findVideo(root) {
    const direct = root.querySelector('video');
    if (direct && direct.videoWidth > 0) return direct;
    for (const node of root.querySelectorAll('*')) {
      if (node.shadowRoot) { const found = findVideo(node.shadowRoot); if (found) return found; }
    }
    return null;
  }
  const video = findVideo(document);
  if (!video) return null;
  const canvas = document.createElement('canvas');
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
  canvas.getContext('2d').drawImage(video, 0, 0);
  return canvas.toDataURL('image/jpeg', 0.95);
};
window.bankingRecognizeText = async (image) => {
  if (!window.Tesseract) {
    await new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/tesseract.js@6.0.1/dist/tesseract.min.js';
      script.onload = resolve; script.onerror = reject; document.head.appendChild(script);
    });
  }
  bankingOcrWorker ??= Tesseract.createWorker('eng').catch(error => { bankingOcrWorker = null; throw error; });
  const worker = await bankingOcrWorker;
  const result = await worker.recognize(image);
  return result.data.text;
};

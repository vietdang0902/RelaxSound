import SwiftUI

struct MixedSoundRow: View {
    let mixedSound: MixedSound
    let originalSound: SoundModel
    var onVolumeChange: (Double) -> Void
    var onRemove: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: "https://sleepchills.kenhtao.site/storage/\(originalSound.imageName)")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                Text(originalSound.title)
                    .font(.headline)
                    .foregroundColor(.white)
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.white)
                    Slider(
                        value: .constant(mixedSound.volume),
                        in: 0 ... 100
                    )
                    .accentColor(.green)
                    .frame(minWidth: 150, maxWidth: 200)
                    .onChange(of: mixedSound.volume) { newValue in
                        onVolumeChange(newValue)
                    }
                    Text(String(format: "%.0f%%", mixedSound.volume))
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                .frame(maxHeight: 30)
            }
            .padding(5)
            Spacer()
            Button(action: onRemove) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 30, height: 30)
                    Image(systemName: "minus")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 10)
            }
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}
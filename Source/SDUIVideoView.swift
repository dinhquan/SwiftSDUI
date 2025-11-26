import AVKit
import Combine
import SwiftUI

struct SDUIVideoView: View {
    @StateObject private var controller: Controller

    init(
        url: URL,
        loop: Bool,
        muted: Bool,
        volume: Float?,
        videoGravity: AVLayerVideoGravity
    ) {
        _controller = StateObject(
            wrappedValue: Controller(
                url: url,
                loop: loop,
                muted: muted,
                volume: volume,
                videoGravity: videoGravity
            )
        )
    }

    var body: some View {
        SDUIVideoPlayerContainer(controller: controller)
            .onAppear { controller.play() }
            .onDisappear { controller.pause() }
    }

    final class Controller: ObservableObject {
        let objectWillChange = ObservableObjectPublisher()
        let player: AVPlayer
        let videoGravity: AVLayerVideoGravity
        private let loop: Bool
        private var endObserver: Any?

        init(
            url: URL,
            loop: Bool,
            muted: Bool,
            volume: Float?,
            videoGravity: AVLayerVideoGravity
        ) {
            self.player = AVPlayer(url: url)
            self.videoGravity = videoGravity
            self.loop = loop

            player.isMuted = muted
            if let volume {
                player.volume = max(0, min(volume, 1))
            }
            player.actionAtItemEnd = loop ? .none : .pause

            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.handleEnd()
            }
        }

        func play() { player.play() }
        func pause() { player.pause() }

        private func handleEnd() {
            guard loop else { return }
            player.seek(to: .zero)
            player.play()
        }

        deinit {
            if let endObserver {
                NotificationCenter.default.removeObserver(endObserver)
            }
        }
    }

    private struct SDUIVideoPlayerContainer: UIViewRepresentable {
        @ObservedObject var controller: Controller

        func makeUIView(context: Context) -> PlayerView {
            let view = PlayerView()
            view.playerLayer.player = controller.player
            view.playerLayer.videoGravity = controller.videoGravity
            return view
        }

        func updateUIView(_ uiView: PlayerView, context: Context) {
            uiView.playerLayer.player = controller.player
            uiView.playerLayer.videoGravity = controller.videoGravity
        }
    }

    private final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}

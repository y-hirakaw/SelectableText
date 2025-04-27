import SwiftUI
import UIKit

// MARK: - テキストスタイル定義
/// テキストのフォント、色、行間、字間などを指定するスタイル情報
struct TextStyle {
    // フォント（サイズ・種類）
    var font: UIFont = UIFont.systemFont(ofSize: 16)
    // フォントの太さ
    var fontWeight: UIFont.Weight = .regular
    // テキストカラー
    var foregroundColor: UIColor = .label
    // 行間
    var lineSpacing: CGFloat = 0
    // 字間（文字間隔）
    var tracking: CGFloat = 0
}

// MARK: - TextStyleプリセット
extension TextStyle {
    /// 普通の長文用（少し行間広め、色はグレー）
    static let multilineText = TextStyle(
        font: .systemFont(ofSize: 16),
        fontWeight: .regular,
        foregroundColor: .gray,
        lineSpacing: 6,
        tracking: 0
    )

    /// タイトル用（大きめ、太字、色は標準）
    static let titleText = TextStyle(
        font: .boldSystemFont(ofSize: 24),
        fontWeight: .bold,
        foregroundColor: .label,
        lineSpacing: 8,
        tracking: 0.5
    )
}

// MARK: - SelectableText（SwiftUI用コンポーネント）
/// テキストを表示し、範囲選択・コピー可能にするためのView
struct SelectableText: View {
    // 表示するテキスト
    let text: String
    // 適用するスタイル（デフォルトあり）
    var style: TextStyle = TextStyle()
    // テキスト量に応じた高さを保持するState
    @State private var height: CGFloat = .zero

    /// 初期化（引数省略スタイル）
    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        GeometryReader { geometry in
            // 親の幅を取得して、その幅に合わせたUITextViewを作成
            SelectableTextView(
                text: text,
                availableWidth: geometry.size.width,
                dynamicHeight: $height,
                style: style
            )
        }
        .frame(height: height)  // テキストサイズに応じた高さを設定
    }
}

// MARK: - SelectableTextモディファイア拡張
extension SelectableText {
    /// テキストスタイルを後から指定できるモディファイア
    func textStyle(_ style: TextStyle) -> SelectableText {
        var copy = self
        copy.style = style
        return copy
    }
}

// MARK: - SelectableTextView内部（UIViewRepresentable）
/// SwiftUI上でUITextViewをラップして使えるようにする
struct SelectableTextView: UIViewRepresentable {
    let text: String
    let availableWidth: CGFloat
    @Binding var dynamicHeight: CGFloat
    let style: TextStyle

    // UITextViewを生成
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        // 編集不可
        textView.isEditable = false
        // 範囲選択可
        textView.isSelectable = true
        // 自動で高さを調整するためスクロール禁止
        textView.isScrollEnabled = false
        // 背景透明
        textView.backgroundColor = .clear
        // 内側余白なし
        textView.textContainerInset = .zero
        // 左右パディングなし
        textView.textContainer.lineFragmentPadding = 0
        // 自動折り返し
        textView.textContainer.lineBreakMode = .byWordWrapping
        // View幅に合わせて自動追従
        textView.textContainer.widthTracksTextView = true
        // AutoLayoutを使う準備
        textView.translatesAutoresizingMaskIntoConstraints = false
        // スタイル適用
        applyStyle(to: textView)
        return textView
    }

    // SwiftUIの更新に応じてUIViewを更新
    func updateUIView(_ uiView: UITextView, context: Context) {
        applyStyle(to: uiView)  // スタイル適用（テキスト変更やスタイル変更に対応）

        // width制約を付与 or 更新（幅に合わせた折り返しを正確にするため）
        if let existingConstraint = uiView.constraints.first(where: {
            $0.identifier == "widthConstraint"
        }) {
            existingConstraint.constant = availableWidth
        } else {
            let widthConstraint = uiView.widthAnchor.constraint(
                equalToConstant: availableWidth
            )
            widthConstraint.identifier = "widthConstraint"
            widthConstraint.isActive = true
        }

        // テキスト量に応じた必要な高さを計算し、Stateに反映
        DispatchQueue.main.async {
            let size = uiView.sizeThatFits(
                CGSize(
                    width: self.availableWidth,
                    height: .greatestFiniteMagnitude
                )
            )
            if self.dynamicHeight != size.height {
                self.dynamicHeight = size.height
            }
        }
    }

    // UITextViewにNSAttributedStringを使ってスタイルを適用
    private func applyStyle(to textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing  // 行間設定

        textView.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(
                    ofSize: style.font.pointSize,
                    weight: style.fontWeight
                ),  // フォントと太さ
                .foregroundColor: style.foregroundColor,  // テキスト色
                .kern: style.tracking,  // 字間
                .paragraphStyle: paragraphStyle,  // 行間設定
            ]
        )
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Hello, world!")
                    .background(Color.red.opacity(0.1))

                SelectableText(
                    "Hello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキストHello, world!テキストテキストテキストテキストテキストテキストテキストテキストテキスト1\nテスト\nテスト2\nテスト3\nテスト4\nテスト5\nテスト6\nテスト7\nテスト8\nテスト9\nテスト10\nテスト11\nテスト12\nテスト13\nテスト14\nテスト15\nテスト16\nテスト17\nテスト18\nテスト19\nテスト20\nテスト21\nテスト22\nテスト23"
                )
                .textStyle(.multilineText)
                .background(Color.green.opacity(0.1))

                SelectableText(
                    "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco lab"
                )
                .textStyle(.titleText)
                .background(Color.blue.opacity(0.1))
                
                Text("普通のテキスト")
                    .background(Color.yellow.opacity(0.1))
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    ContentView()
}

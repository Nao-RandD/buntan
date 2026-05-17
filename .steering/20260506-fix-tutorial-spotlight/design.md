# Design: チュートリアルスポットライト修正

## 実装アプローチ

### コアテクニック: even-odd fill rule によるくり抜き

`SpotlightShape: Shape` を新規定義し、全画面 `Rectangle` の内側に「+」ボタンの丸角矩形パスを追加する。`FillStyle(eoFill: true)` で塗りつぶすと、内側パスが「穴」になりスポットライト効果を実現する。

```
┌──────────────────────────────┐
│ 暗いオーバーレイ（外側パス）   │
│                              │
│  ┌──────┐  ← くり抜き（穴）   │
│  │  +   │                    │
│  └──────┘                    │
│                              │
└──────────────────────────────┘
```

### フレーム取得: `.onGeometryChange` + 引数渡し

`fullScreenCover` は同一 `UIWindow` 内でモーダル表示されるため、`.global` 座標系は HomeView と TutorialView で一致する。

HomeView でフレームを取得 → `let` 引数として TutorialView に渡す。

```
HomeView                      TutorialView
─────────────────────────     ─────────────────────────
「+」ボタン
  .onGeometryChange ──── plusButtonFrame: CGRect ────→  SpotlightShape
                                                         グロー枠
                                                         ツールチップ
```

**`.onGeometryChange` を選んだ理由:**  
ToolbarItem のラベルは leaf view のため、`GeometryReader` でラップするとレイアウトが崩れる。`.onGeometryChange`（iOS 17+）はレイアウト非干渉で、iOS 18 minimum に適合する。

---

## 変更コンポーネント

### TutorialView.swift（完全書き直し）

| 追加要素 | 役割 |
|---------|------|
| `SpotlightShape: Shape` | even-odd くり抜きオーバーレイ |
| `animatableData` | ステップ間アニメーション対応（将来の多ステップ化に備え） |
| グロー枠 `RoundedRectangle.stroke` | ボタン周囲の白い境界線 |
| ツールチップ `VStack` | 三角矢印 + 吹き出しテキスト、`plusButtonFrame.maxY` 基準で配置 |
| `plusButtonFrame: CGRect` 引数 | HomeView から受け取る実フレーム |

### HomeView.swift（最小変更）

| 変更箇所 | 内容 |
|---------|------|
| `@State private var plusButtonFrame: CGRect = .zero` | フレーム保持用 State 追加 |
| 「+」ボタンラベルに `.onGeometryChange` | `.global` 座標でフレーム取得 |
| `fullScreenCover` の引数 | `plusButtonFrame` を追加 |

---

## データ構造変更

なし。`CGRect` を State として保持するのみ。

---

## 影響範囲

- `TutorialView` の呼び出し元は `HomeView` のみ（他画面への影響なし）
- `AppViewModel` への変更なし
- dismiss ロジック（`appVM.isShowTutorial`）は変更なし

---

## フォールバック設計

`plusButtonFrame == .zero`（フレーム未取得）の場合、`SpotlightShape` は `.zero` の CGRect でくり抜きサイズがゼロになるため、実質的に全画面オーバーレイとして機能する（既存動作に近い見た目）。ツールチップも `offset(y: 50)` の固定位置にフォールバックする。

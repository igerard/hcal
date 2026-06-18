//
//  HelpView.swift
//  JCal
//
//  Concise, localized help: how to use the app and what the category colors mean.
//  Shown as a toolbar popover and as a window from the Help menu.
//

import SwiftUI

struct HelpView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("JCal Help")
        .font(.title3.bold())

      VStack(alignment: .leading, spacing: 6) {
        Text("Getting around")
          .font(.headline)
        Label("Click a day to read its holidays and events.", systemImage: "hand.tap")
        Label("Switch calendar and area from the toolbar.", systemImage: "calendar")
        Label("Toggle the Parsha, Omer and Chol Hamoed icons to show them.", systemImage: "switch.2")
        Label("Arrow keys change month and year; ⌘T jumps to today.", systemImage: "arrow.left.arrow.right")
      }

      Divider()

      VStack(alignment: .leading, spacing: 6) {
        Text("Color legend")
          .font(.headline)
        ForEach(HolidayInfo.Category.allCases, id: \.self) { category in
          HStack(spacing: 8) {
            Circle()
              .fill(Theming.holidayCategoryColor(category))
              .frame(width: 10, height: 10)
            Text(category.localizedName)
          }
        }
      }

      Divider()

      VStack(alignment: .leading, spacing: 4) {
        Text("Credits")
          .font(.headline)
        Text("JCal is a fork of the original open-source project by Avraham Drissman and Frank Yellin (BSD 3-Clause License, 2018). App icon by Jomy Muttathil. Hebrew-calendar algorithms adapted from the GNU Emacs calendar code.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .font(.callout)
    .padding(16)
    .frame(width: 320, alignment: .leading)
  }
}

/// Menu item (Help menu) that opens the help window.
struct HelpMenuButton: View {
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Button("JCal Help") {
      openWindow(id: "help")
    }
    .keyboardShortcut("?", modifiers: [.command])
  }
}

#Preview {
  HelpView()
}

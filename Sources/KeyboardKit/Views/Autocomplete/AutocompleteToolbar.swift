//
//  AutocompleteToolbar.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-09-13.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This view is a horizontal row with autocomplete buttons and
 separator lines between the buttons.
 
 You can customize the button and the separator by injecting
 a custom `buttonBuilder` and/or `separatorBuilder`. You can
 also customize the `replacementAction` to determine what an
 autocomplete suggestion should do when it's tapped.
 
 Note that the views that are returned by the `buttonBuilder`
 will be nested in a button that triggers `replacementAction`.
 You should therefore only return views and not buttons when
 you provide a custom `buttonBuilder`.
 */
public struct AutocompleteToolbar<ItemView: View, SeparatorView: View>: View {
    
    /**
     Create an autocomplete toolbar.

     - Parameters:
       - suggestions: A list of suggestions to display in the toolbar.
       - locale: The locale to apply to the toolbar.
       - style: The style to apply to the toolbar, by default `.standard`.
       - itemView: An item view builder that is used to build a view for each suggestion.
       - separatorView: A separator view builder a view for each separator.
       - action: The action to use when tapping a suggestion. By default, the static `standardReplacementAction` will be used.
     */
    public init(
        suggestions: [AutocompleteSuggestion],
        locale: Locale,
        style: AutocompleteToolbarStyle = .standard,
        itemView: @escaping ItemViewBuilder,
        separatorView: @escaping SeparatorViewBuilder,
        action: @escaping ReplacementAction = standardAction) {
        self.items = suggestions.map { BarItem($0) }
        self.itemView = itemView
        self.locale = locale
        self.style = style
        self.separatorView = separatorView
        self.action = action
    }
    
    private let items: [BarItem]
    private let locale: Locale
    private let style: AutocompleteToolbarStyle
    private let action: ReplacementAction
    private let itemView: ItemViewBuilder
    private let separatorView: SeparatorViewBuilder
    
    
    /**
     This typealias represents the action block that is used
     to create autocomplete item views.
     */
    public typealias ItemViewBuilder = (AutocompleteSuggestion, Locale, AutocompleteToolbarStyle) -> ItemView
    
    /**
     This typealias represents the action block that is used
     to create autocomplete item separator views.
     */
    public typealias SeparatorViewBuilder = (AutocompleteSuggestion, AutocompleteToolbarStyle) -> SeparatorView
    
    
    /**
     This internal struct is used to encapsulate item data.
     */
    struct BarItem: Identifiable {
        
        init(_ suggestion: AutocompleteSuggestion) {
            self.suggestion = suggestion
        }
        
        public let id = UUID()
        public let suggestion: AutocompleteSuggestion
    }

    /**
     This typealias represents the action block that is used
     to trigger a text replacement when tapping a suggestion.
     */
    public typealias ReplacementAction = (AutocompleteSuggestion) -> Void

    public var body: some View {
        HStack {
            ForEach(items) { item in
                itemButton(for: item.suggestion)
                if useSeparator(for: item) {
                    separatorView(item.suggestion, style)
                }
            }
        }
    }
}

public extension AutocompleteToolbar where ItemView == AutocompleteToolbarItem {
    
    /**
     Create an autocomplete toolbar with standard item views.

     - Parameters:
       - suggestions: A list of suggestions to display in the toolbar.
       - locale: The locale to apply to the toolbar.
       - style: The style to apply to the toolbar, by default `.standard`.
       - separatorView: A separator view builder a view for each separator.
       - action: The action to use when tapping a suggestion. By default, the static `standardReplacementAction` will be used.
     */
    init(
        suggestions: [AutocompleteSuggestion],
        locale: Locale,
        style: AutocompleteToolbarStyle = .standard,
        separatorView: @escaping SeparatorViewBuilder,
        action: @escaping ReplacementAction = standardAction) {
        self.items = suggestions.map { BarItem($0) }
        self.locale = locale
        self.style = style
        self.separatorView = separatorView
        self.action = action
            
        self.itemView = { AutocompleteToolbarItem(
            suggestion: $0,
            style: $2.item,
            locale: $1)
        }
    }
}

public extension AutocompleteToolbar where ItemView == AutocompleteToolbarItem, SeparatorView == AutocompleteToolbarSeparator {
    
    /**
     Create an autocomplete toolbar with standard item views
     and separator views.

     - Parameters:
       - suggestions: A list of suggestions to display in the toolbar.
       - locale: The locale to apply to the toolbar.
       - style: The style to apply to the toolbar, by default `.standard`.
       - action: The action to use when tapping a suggestion. By default, the static `standardReplacementAction` will be used.
     */
    init(
        suggestions: [AutocompleteSuggestion],
        locale: Locale,
        style: AutocompleteToolbarStyle = .standard,
        action: @escaping ReplacementAction = standardAction) {
        self.items = suggestions.map { BarItem($0) }
        self.locale = locale
        self.style = style
        self.action = action
            
        self.itemView = { AutocompleteToolbarItem(
            suggestion: $0,
            style: $2.item,
            locale: $1)
        }
            
        self.separatorView = { AutocompleteToolbarSeparator(
            style: $1.separator)
        }
    }
}

public extension AutocompleteToolbar where SeparatorView == AutocompleteToolbarSeparator {
    
    /**
     Create an autocomplete toolbar with standard separators.

     - Parameters:
       - suggestions: A list of suggestions to display in the toolbar.
       - locale: The locale to apply to the toolbar.
       - style: The style to apply to the toolbar, by default `.standard`.
       - itemView: An item view builder that is used to build a view for each suggestion.
       - action: The action to use when tapping a suggestion. By default, the static `standardReplacementAction` will be used.
     */
    init(
        suggestions: [AutocompleteSuggestion],
        locale: Locale,
        style: AutocompleteToolbarStyle = .standard,
        itemView: @escaping ItemViewBuilder,
        action: @escaping ReplacementAction = standardAction) {
        self.items = suggestions.map { BarItem($0) }
        self.locale = locale
        self.style = style
        self.action = action
        self.itemView = itemView
            
        self.separatorView = { AutocompleteToolbarSeparator(
            style: $1.separator)
        }
    }
}

public extension AutocompleteToolbar {
    
    /**
     This is the default action that will be used to trigger
     a text replacement when a `suggestion` is tapped.
     */
    static func standardAction(
        for suggestion: AutocompleteSuggestion) {
        let proxy = KeyboardInputViewController.shared.textDocumentProxy
        let actionHandler = KeyboardInputViewController.shared.keyboardActionHandler
        proxy.insertAutocompleteSuggestion(suggestion)
        actionHandler.handle(.tap, on: .character(""))
    }
}

private extension AutocompleteToolbar {
    
    func itemButton(for suggestion: AutocompleteSuggestion) -> some View {
        Button(action: { action(suggestion) }) {
            itemView(suggestion, locale, style)
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                .background(suggestion.isAutocomplete ? style.autocompleteBackground.color : Color.clearInteractable)
                .cornerRadius(style.autocompleteBackground.cornerRadius)
        }
        .background(Color.clearInteractable)
        .buttonStyle(PlainButtonStyle())
    }
}

private extension AutocompleteToolbar {
    
    func isLast(_ item: BarItem) -> Bool {
        item.id == items.last?.id
    }
    
    func isNextItemAutocomplete(for item: BarItem) -> Bool {
        guard let index = (items.firstIndex { $0.id == item.id }) else { return false }
        let nextIndex = items.index(after: index)
        guard nextIndex < items.count else { return false }
        return items[nextIndex].suggestion.isAutocomplete
    }
    
    func useSeparator(for item: BarItem) -> Bool {
        if item.suggestion.isAutocomplete { return false }
        if isLast(item) { return false }
        return !isNextItemAutocomplete(for: item)
    }
}

struct AutocompleteToolbar_Previews: PreviewProvider {
    
    static var previews: some View {
        KeyboardInputViewController.shared = .preview
        let additionalSuggestion = StandardAutocompleteSuggestion(text: "", title: "Foo", subtitle: "Recommended")
        return VStack {
            AutocompleteToolbar(
                suggestions: previewSuggestions,
                locale: KeyboardLocale.english.locale,
                style: .standard).previewBar()
            AutocompleteToolbar(
                suggestions: previewSuggestions + [additionalSuggestion],
                locale: KeyboardLocale.spanish.locale,
                style: .standard).previewBar()
            AutocompleteToolbar(
                suggestions: previewSuggestions + [additionalSuggestion],
                locale: KeyboardLocale.spanish.locale,
                style: .preview1).previewBar()
            AutocompleteToolbar(
                suggestions: previewSuggestions + [additionalSuggestion],
                locale: KeyboardLocale.spanish.locale,
                style: .preview2).previewBar()
            AutocompleteToolbar(
                suggestions: previewSuggestions,
                locale: KeyboardLocale.swedish.locale,
                style: .standard,
                itemView: previewItem).previewBar()
        }
        .padding()
    }
    
    static func previewItem(for suggestion: AutocompleteSuggestion, locale: Locale, style: AutocompleteToolbarStyle) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                AutocompleteToolbarItemTitle(
                    suggestion: suggestion,
                    style: style.item,
                    locale: KeyboardLocale.swedish.locale)
                    .font(Font.body.bold())
                if let subtitle = suggestion.subtitle {
                    Text(subtitle).font(.footnote)
                }
            }
            Spacer()
        }
    }
    
    static let previewSuggestions: [AutocompleteSuggestion] = [
        StandardAutocompleteSuggestion("Baz", isUnknown: true),
        StandardAutocompleteSuggestion("Bar", isAutocomplete: true),
        StandardAutocompleteSuggestion(text: "", title: "Foo", subtitle: "Recommended")]
}

private extension View {
    
    func previewBar() -> some View {
        self.background(Color.gray.opacity(0.3))
            .cornerRadius(10)
    }
}

//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)
  
  static func validate() throws {
    try intern.validate()
  }
  
  /// This `R.color` struct is generated, and contains static references to 0 color palettes.
  struct color {
    fileprivate init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 1 files.
  struct file {
    /// Resource file `style_json.json`.
    static let style_jsonJson = Rswift.FileResource(bundle: R.hostingBundle, name: "style_json", pathExtension: "json")
    
    /// `bundle.url(forResource: "style_json", withExtension: "json")`
    static func style_jsonJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.style_jsonJson
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 0 fonts.
  struct font {
    fileprivate init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 38 images.
  struct image {
    /// Image `bg_wite_card`.
    static let bg_wite_card = Rswift.ImageResource(bundle: R.hostingBundle, name: "bg_wite_card")
    /// Image `icon_add`.
    static let icon_add = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_add")
    /// Image `icon_arrow_down`.
    static let icon_arrow_down = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_arrow_down")
    /// Image `icon_arrow_left`.
    static let icon_arrow_left = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_arrow_left")
    /// Image `icon_arrow_right`.
    static let icon_arrow_right = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_arrow_right")
    /// Image `icon_arrow_up`.
    static let icon_arrow_up = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_arrow_up")
    /// Image `icon_calendar`.
    static let icon_calendar = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_calendar")
    /// Image `icon_close`.
    static let icon_close = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_close")
    /// Image `icon_comment`.
    static let icon_comment = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_comment")
    /// Image `icon_commit`.
    static let icon_commit = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_commit")
    /// Image `icon_delete`.
    static let icon_delete = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_delete")
    /// Image `icon_downlooad`.
    static let icon_downlooad = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_downlooad")
    /// Image `icon_edit`.
    static let icon_edit = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_edit")
    /// Image `icon_file`.
    static let icon_file = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_file")
    /// Image `icon_filter`.
    static let icon_filter = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_filter")
    /// Image `icon_folder`.
    static let icon_folder = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_folder")
    /// Image `icon_full_screen`.
    static let icon_full_screen = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_full_screen")
    /// Image `icon_like`.
    static let icon_like = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_like")
    /// Image `icon_link`.
    static let icon_link = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_link")
    /// Image `icon_lock`.
    static let icon_lock = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_lock")
    /// Image `icon_logout`.
    static let icon_logout = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_logout")
    /// Image `icon_message`.
    static let icon_message = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_message")
    /// Image `icon_more`.
    static let icon_more = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_more")
    /// Image `icon_printer`.
    static let icon_printer = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_printer")
    /// Image `icon_refresh`.
    static let icon_refresh = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_refresh")
    /// Image `icon_resize_ horizontal`.
    static let icon_resize_Horizontal = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_resize_ horizontal")
    /// Image `icon_resize_vertical`.
    static let icon_resize_vertical = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_resize_vertical")
    /// Image `icon_search`.
    static let icon_search = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_search")
    /// Image `icon_setting`.
    static let icon_setting = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_setting")
    /// Image `icon_share`.
    static let icon_share = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_share")
    /// Image `icon_to`.
    static let icon_to = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_to")
    /// Image `icon_user`.
    static let icon_user = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_user")
    /// Image `map_mine_location`.
    static let map_mine_location = Rswift.ImageResource(bundle: R.hostingBundle, name: "map_mine_location")
    /// Image `map_pio_location`.
    static let map_pio_location = Rswift.ImageResource(bundle: R.hostingBundle, name: "map_pio_location")
    /// Image `map_select_location`.
    static let map_select_location = Rswift.ImageResource(bundle: R.hostingBundle, name: "map_select_location")
    /// Image `map_select_point`.
    static let map_select_point = Rswift.ImageResource(bundle: R.hostingBundle, name: "map_select_point")
    /// Image `map_switch_to_location`.
    static let map_switch_to_location = Rswift.ImageResource(bundle: R.hostingBundle, name: "map_switch_to_location")
    /// Image `title_label`.
    static let title_label = Rswift.ImageResource(bundle: R.hostingBundle, name: "title_label")
    
    /// `UIImage(named: "bg_wite_card", bundle: ..., traitCollection: ...)`
    static func bg_wite_card(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.bg_wite_card, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_add", bundle: ..., traitCollection: ...)`
    static func icon_add(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_add, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_arrow_down", bundle: ..., traitCollection: ...)`
    static func icon_arrow_down(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_arrow_down, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_arrow_left", bundle: ..., traitCollection: ...)`
    static func icon_arrow_left(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_arrow_left, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_arrow_right", bundle: ..., traitCollection: ...)`
    static func icon_arrow_right(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_arrow_right, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_arrow_up", bundle: ..., traitCollection: ...)`
    static func icon_arrow_up(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_arrow_up, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_calendar", bundle: ..., traitCollection: ...)`
    static func icon_calendar(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_calendar, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_close", bundle: ..., traitCollection: ...)`
    static func icon_close(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_close, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_comment", bundle: ..., traitCollection: ...)`
    static func icon_comment(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_comment, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_commit", bundle: ..., traitCollection: ...)`
    static func icon_commit(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_commit, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_delete", bundle: ..., traitCollection: ...)`
    static func icon_delete(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_delete, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_downlooad", bundle: ..., traitCollection: ...)`
    static func icon_downlooad(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_downlooad, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_edit", bundle: ..., traitCollection: ...)`
    static func icon_edit(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_edit, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_file", bundle: ..., traitCollection: ...)`
    static func icon_file(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_file, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_filter", bundle: ..., traitCollection: ...)`
    static func icon_filter(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_filter, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_folder", bundle: ..., traitCollection: ...)`
    static func icon_folder(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_folder, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_full_screen", bundle: ..., traitCollection: ...)`
    static func icon_full_screen(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_full_screen, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_like", bundle: ..., traitCollection: ...)`
    static func icon_like(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_like, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_link", bundle: ..., traitCollection: ...)`
    static func icon_link(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_link, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_lock", bundle: ..., traitCollection: ...)`
    static func icon_lock(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_lock, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_logout", bundle: ..., traitCollection: ...)`
    static func icon_logout(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_logout, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_message", bundle: ..., traitCollection: ...)`
    static func icon_message(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_message, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_more", bundle: ..., traitCollection: ...)`
    static func icon_more(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_more, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_printer", bundle: ..., traitCollection: ...)`
    static func icon_printer(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_printer, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_refresh", bundle: ..., traitCollection: ...)`
    static func icon_refresh(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_refresh, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_resize_ horizontal", bundle: ..., traitCollection: ...)`
    static func icon_resize_Horizontal(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_resize_Horizontal, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_resize_vertical", bundle: ..., traitCollection: ...)`
    static func icon_resize_vertical(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_resize_vertical, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_search", bundle: ..., traitCollection: ...)`
    static func icon_search(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_search, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_setting", bundle: ..., traitCollection: ...)`
    static func icon_setting(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_setting, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_share", bundle: ..., traitCollection: ...)`
    static func icon_share(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_share, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_to", bundle: ..., traitCollection: ...)`
    static func icon_to(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_to, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "icon_user", bundle: ..., traitCollection: ...)`
    static func icon_user(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_user, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "map_mine_location", bundle: ..., traitCollection: ...)`
    static func map_mine_location(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.map_mine_location, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "map_pio_location", bundle: ..., traitCollection: ...)`
    static func map_pio_location(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.map_pio_location, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "map_select_location", bundle: ..., traitCollection: ...)`
    static func map_select_location(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.map_select_location, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "map_select_point", bundle: ..., traitCollection: ...)`
    static func map_select_point(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.map_select_point, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "map_switch_to_location", bundle: ..., traitCollection: ...)`
    static func map_switch_to_location(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.map_switch_to_location, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "title_label", bundle: ..., traitCollection: ...)`
    static func title_label(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.title_label, compatibleWith: traitCollection)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 0 nibs.
  struct nib {
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 0 reuse identifiers.
  struct reuseIdentifier {
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 0 view controllers.
  struct segue {
    fileprivate init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }
    
    fileprivate init() {}
  }
  
  fileprivate class Class {}
  
  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    try storyboard.validate()
  }
  
  struct nib {
    fileprivate init() {}
  }
  
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      try launchScreen.validate()
    }
    
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController
      
      let bundle = R.hostingBundle
      let name = "LaunchScreen"
      
      static func validate() throws {
        if UIKit.UIImage(named: "title_label") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'title_label' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}
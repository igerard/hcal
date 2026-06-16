//
//  HolidayInfo.swift
//  JCal
//
//  Bridges the C holiday engine to localized, human-readable explanations
//  shown in the day popover.
//

import Foundation

enum HolidayInfo {

  /// All holiday/event names the engine returns for a secular date, honoring the
  /// current Parsha / Omer / Chol toggles and the selected holiday area.
  static func names(for date: SimpleDate, in model: HebrewCalendar) -> [String] {
    // The engine reads these globals to decide whether to emit Parsha / Omer /
    // Chol Hamoed entries.
    ParshaP = model.parchaActive
    OmerP = model.omerActive
    CholP = model.cholActive

    let hdate = SecularToHebrewConversion(date.year,
                                          date.month,
                                          date.day,
                                          model.calendarType == .julian)
    guard let base = FindHoliday(Int32(hdate.month),
                                 Int32(hdate.day),
                                 Int32(hdate.day_of_week),
                                 Int32(hdate.kvia),
                                 hdate.hebrew_leap_year_p,
                                 model.holidayArea == .israel,
                                 Int32(hdate.hebrew_day_number),
                                 Int32(hdate.year)) else {
      return []
    }

    var result: [String] = []
    for i in 0..<5 {                       // FindHoliday returns up to 5 slots
      guard let cstr = base.advanced(by: i).pointee else { break }
      result.append(String(cString: cstr))
    }
    return result
  }

  /// A localized explanation for a holiday code returned by the engine.
  static func explanation(for name: String) -> String {
    // Counting of the Omer: any "Nth day Omer" produced by the engine.
    if name.hasSuffix("Omer") && name != "Lag BaOmer" {
      return String(localized: "Counting of the Omer: the 49 days counted from the second night of Pesach until Shavuot.")
    }

    switch name {
    case "Sh. HaHodesh":
      return String(localized: "Shabbat HaHodesh: the special Shabbat before the month of Nissan, announcing the new month and the laws of Pesach.")
    case "Erev Pesach":
      return String(localized: "Erev Pesach: the eve of Passover, when leaven is removed and the Seder is prepared.")
    case "Sh. HaGadol":
      return String(localized: "Shabbat HaGadol: the \u{201C}Great Shabbat\u{201D} immediately before Pesach.")
    case "Pesach":
      return String(localized: "Pesach (Passover): commemorates the Exodus from Egypt; matzah is eaten and leaven avoided.")
    case "Chol Hamoed":
      return String(localized: "Chol Hamoed: the intermediate festival days of Pesach or Sukkot.")
    case "Yom HaShoah":
      return String(localized: "Yom HaShoah: Holocaust Remembrance Day, honoring the victims of the Shoah.")
    case "Yom HaZikaron":
      return String(localized: "Yom HaZikaron: Israel\u{2019}s Memorial Day for fallen soldiers and victims of terror.")
    case "Yom HaAtzmaut":
      return String(localized: "Yom HaAtzmaut: Israeli Independence Day, marking the 1948 declaration of the State of Israel.")
    case "Yom Yerushalayim":
      return String(localized: "Yom Yerushalayim: Jerusalem Day, commemorating the reunification of Jerusalem in 1967.")
    case "Lag BaOmer":
      return String(localized: "Lag BaOmer: the 33rd day of the Omer, a festive break in the period of mourning.")
    case "Erev Shavuot":
      return String(localized: "Erev Shavuot: the eve of Shavuot.")
    case "Shavuot":
      return String(localized: "Shavuot: the Feast of Weeks, commemorating the giving of the Torah at Sinai.")
    case "Tzom Tamuz":
      return String(localized: "Tzom Tammuz: the fast of the 17th of Tammuz, marking the breach of Jerusalem\u{2019}s walls.")
    case "Sh. Hazon":
      return String(localized: "Shabbat Hazon: the Shabbat before Tisha B\u{2019}Av, named for the vision of Isaiah.")
    case "Sh. Nahamu":
      return String(localized: "Shabbat Nahamu: the Shabbat of comfort following Tisha B\u{2019}Av.")
    case "Tisha B'Av":
      return String(localized: "Tisha B\u{2019}Av: the fast mourning the destruction of both Temples in Jerusalem.")
    case "S'lichot (evening)":
      return String(localized: "Selichot: penitential prayers recited in the run-up to the High Holy Days.")
    case "Erev R.H.":
      return String(localized: "Erev Rosh Hashanah: the eve of the Jewish New Year.")
    case "Rosh Hashonah":
      return String(localized: "Rosh Hashanah: the Jewish New Year and Day of Judgment, when the shofar is sounded.")
    case "Sh. Shuvah":
      return String(localized: "Shabbat Shuvah: the Shabbat of Return, between Rosh Hashanah and Yom Kippur.")
    case "Tzom Gedaliah":
      return String(localized: "Tzom Gedaliah: the fast marking the assassination of Gedaliah, governor of Judah.")
    case "Erev Y.K.":
      return String(localized: "Erev Yom Kippur: the eve of the Day of Atonement.")
    case "Yom Kippur":
      return String(localized: "Yom Kippur: the Day of Atonement, the holiest day of the year, observed with fasting and prayer.")
    case "Erev Sukkot":
      return String(localized: "Erev Sukkot: the eve of Sukkot.")
    case "Sukkot":
      return String(localized: "Sukkot: the Feast of Tabernacles, dwelling in booths to recall the wilderness journey.")
    case "Hoshanah Rabah":
      return String(localized: "Hoshanah Rabah: the seventh day of Sukkot, marked by special processions and prayers.")
    case "Shmini Atzeret":
      return String(localized: "Shmini Atzeret: the festival concluding Sukkot, including the prayer for rain.")
    case "Simchat Torah":
      return String(localized: "Simchat Torah: rejoicing of the Torah, celebrating the completion of the annual reading cycle.")
    case "Erev Hanukah":
      return String(localized: "Erev Hanukah: the eve of Hanukah.")
    case "Hanukah":
      return String(localized: "Hanukah: the eight-day Festival of Lights, commemorating the rededication of the Temple.")
    case "Tzom Tevet":
      return String(localized: "Tzom Tevet: the fast of the 10th of Tevet, marking the siege of Jerusalem.")
    case "Sh. Shirah":
      return String(localized: "Shabbat Shirah: the Shabbat of the Song of the Sea (Exodus 15).")
    case "Tu B'Shvat":
      return String(localized: "Tu BiShvat: the New Year for Trees.")
    case "Sh. Shekalim":
      return String(localized: "Shabbat Shekalim: the first of four special Shabbatot before Pesach.")
    case "Purim Katan":
      return String(localized: "Purim Katan: the \u{201C}Minor Purim\u{201D} in Adar I of a leap year.")
    case "Sh. Zachor":
      return String(localized: "Shabbat Zachor: the Shabbat before Purim, recalling the command to remember Amalek.")
    case "Ta'anit Ester":
      return String(localized: "Ta\u{2019}anit Esther: the Fast of Esther, observed the day before Purim.")
    case "Erev Purim":
      return String(localized: "Erev Purim: the eve of Purim.")
    case "Purim":
      return String(localized: "Purim: celebrates the deliverance of the Jews of Persia, recounted in the Book of Esther.")
    case "Shushan Purim":
      return String(localized: "Shushan Purim: Purim as observed a day later in walled cities such as Jerusalem.")
    case "Sh. Parah":
      return String(localized: "Shabbat Parah: a special Shabbat after Purim concerning ritual purification.")
    default:
      // Any other code is the weekly Torah portion (Parsha) from FindParshaName.
      return String(localized: "Parashat \(name): the weekly Torah portion read on this Shabbat.")
    }
  }

  // MARK: - Categories

  /// Broad category a holiday code belongs to, used to color-code the popover.
  enum Category: CaseIterable {
    case majorFestival
    case intermediate
    case minorFestival
    case fast
    case modernIsraeli
    case specialShabbat
    case omer
    case eve
    case parsha

    var localizedName: String {
      switch self {
      case .majorFestival:  return String(localized: "Major festival")
      case .intermediate:   return String(localized: "Intermediate days")
      case .minorFestival:  return String(localized: "Minor festival")
      case .fast:           return String(localized: "Fast day")
      case .modernIsraeli:  return String(localized: "Israeli national day")
      case .specialShabbat: return String(localized: "Special Shabbat")
      case .omer:           return String(localized: "Counting of the Omer")
      case .eve:            return String(localized: "Festival eve")
      case .parsha:         return String(localized: "Weekly Torah portion")
      }
    }
  }

  static func category(for name: String) -> Category {
    if name.hasPrefix("Erev") || name == "S'lichot (evening)" { return .eve }
    if name.hasSuffix("Omer") && name != "Lag BaOmer" { return .omer }
    if name.hasPrefix("Sh. ") { return .specialShabbat }

    switch name {
    case "Pesach", "Shavuot", "Sukkot", "Rosh Hashonah", "Yom Kippur",
         "Shmini Atzeret", "Simchat Torah":
      return .majorFestival
    case "Chol Hamoed", "Hoshanah Rabah":
      return .intermediate
    case "Hanukah", "Purim", "Shushan Purim", "Purim Katan", "Tu B'Shvat", "Lag BaOmer":
      return .minorFestival
    case "Tzom Tamuz", "Tisha B'Av", "Tzom Gedaliah", "Tzom Tevet", "Ta'anit Ester":
      return .fast
    case "Yom HaShoah", "Yom HaZikaron", "Yom HaAtzmaut", "Yom Yerushalayim":
      return .modernIsraeli
    default:
      return .parsha
    }
  }
}

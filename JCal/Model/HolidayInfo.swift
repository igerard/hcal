//
//  HolidayInfo.swift
//  JCal
//
//  Bridges the C holiday engine to localized, human-readable explanations
//  shown in the day popover, plus a "Learn more" Wikipedia link per holiday.
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

  /// A localized, enriched explanation for a holiday code returned by the engine.
  static func explanation(for name: String) -> String {
    // Counting of the Omer: any "Nth day Omer" produced by the engine.
    if name.hasSuffix("Omer") && name != "Lag BaOmer" {
      return String(localized: "Counting of the Omer: the daily count of the 49 days from the second night of Pesach to Shavuot. Each evening the new day is recited, linking the Exodus to the giving of the Torah.")
    }

    switch name {
    case "Sh. HaHodesh":
      return String(localized: "Shabbat HaHodesh: the last of the four special Shabbatot, on or before Rosh Chodesh Nissan. An added Torah reading (Exodus 12) gives the laws of the Passover offering and announces the month of redemption.")
    case "Erev Pesach":
      return String(localized: "Erev Pesach: the eve of Passover (14 Nissan). The morning is devoted to removing and burning chametz, firstborn traditionally fast, and the Seder begins that night.")
    case "Sh. HaGadol":
      return String(localized: "Shabbat HaGadol: the \u{201C}Great Shabbat\u{201D} right before Pesach, traditionally marked by a rabbinic discourse on the laws of the festival.")
    case "Pesach":
      return String(localized: "Pesach (Passover): begins 15 Nissan, lasting seven days in Israel and eight in the Diaspora. It commemorates the Exodus from Egypt; Jews eat matzah, avoid leaven, and retell the story at the Seder.")
    case "Chol Hamoed":
      return String(localized: "Chol Hamoed: the intermediate days of Pesach and Sukkot, between the opening and closing holy days. Some work is permitted while the festive character continues.")
    case "Yom HaShoah":
      return String(localized: "Yom HaShoah (27 Nissan): Israel\u{2019}s Holocaust Remembrance Day, honoring the six million Jews murdered in the Shoah. A national siren brings the country to a standstill.")
    case "Yom HaZikaron":
      return String(localized: "Yom HaZikaron (4 Iyar): Israel\u{2019}s Memorial Day for fallen soldiers and victims of terrorism, observed with sirens and ceremonies the day before Independence Day.")
    case "Yom HaAtzmaut":
      return String(localized: "Yom HaAtzmaut (5 Iyar): Israeli Independence Day, marking the 1948 declaration of the State of Israel, celebrated right after Yom HaZikaron.")
    case "Yom Yerushalayim":
      return String(localized: "Yom Yerushalayim (28 Iyar): Jerusalem Day, commemorating the reunification of Jerusalem during the 1967 Six-Day War.")
    case "Lag BaOmer":
      return String(localized: "Lag BaOmer (18 Iyar): the 33rd day of the Omer and a joyful pause in its semi-mourning, associated with Rabbi Shimon bar Yochai. Customs include bonfires, weddings, and outings.")
    case "Erev Shavuot":
      return String(localized: "Erev Shavuot: the eve of Shavuot, at the end of the seven-week Omer count. Many stay up studying Torah through the night (Tikkun Leil Shavuot).")
    case "Shavuot":
      return String(localized: "Shavuot (6 Sivan): the Feast of Weeks, fifty days after Passover, marking the giving of the Torah at Sinai. An ancient harvest festival, it is observed with all-night study and dairy foods.")
    case "Tzom Tamuz":
      return String(localized: "Tzom Tammuz (17 Tammuz): a dawn-to-dusk fast recalling the breaching of Jerusalem\u{2019}s walls. It opens the Three Weeks of mourning leading to Tisha B\u{2019}Av.")
    case "Sh. Hazon":
      return String(localized: "Shabbat Hazon: the Shabbat before Tisha B\u{2019}Av, named for the opening \u{201C}vision\u{201D} (chazon) of Isaiah read as the haftarah. It falls within the mournful Nine Days.")
    case "Sh. Nahamu":
      return String(localized: "Shabbat Nahamu: the Shabbat after Tisha B\u{2019}Av, named for the haftarah\u{2019}s words of comfort, \u{201C}Nachamu, nachamu ami.\u{201D} It begins seven weeks of consolation toward the High Holy Days.")
    case "Tisha B'Av":
      return String(localized: "Tisha B\u{2019}Av (9 Av): the major fast mourning the destruction of both Temples in Jerusalem and later tragedies. A 25-hour fast with restrictions like Yom Kippur, it includes the reading of Lamentations.")
    case "S'lichot (evening)":
      return String(localized: "Selichot: penitential prayers said before and during the High Holy Days. In the Ashkenazi rite they begin late on the Saturday night before Rosh Hashanah.")
    case "Erev R.H.":
      return String(localized: "Erev Rosh Hashanah (29 Elul): the eve of the Jewish New Year, with candle-lighting and festive meals featuring symbolic foods.")
    case "Rosh Hashonah":
      return String(localized: "Rosh Hashanah (1-2 Tishrei): the Jewish New Year and Day of Judgment. The shofar is sounded, opening the Ten Days of Repentance toward Yom Kippur.")
    case "Sh. Shuvah":
      return String(localized: "Shabbat Shuvah: the \u{201C}Sabbath of Return\u{201D} between Rosh Hashanah and Yom Kippur, named for the haftarah\u{2019}s call to repentance (\u{201C}Shuvah Yisrael\u{201D}).")
    case "Tzom Gedaliah":
      return String(localized: "Tzom Gedaliah (3 Tishrei): a dawn-to-dusk fast marking the assassination of Gedaliah, governor of Judah, which ended Jewish self-rule after the First Temple\u{2019}s destruction.")
    case "Erev Y.K.":
      return String(localized: "Erev Yom Kippur (9 Tishrei): the eve of the Day of Atonement, marked by a festive meal before the fast, charity, and seeking forgiveness from others.")
    case "Yom Kippur":
      return String(localized: "Yom Kippur (10 Tishrei): the Day of Atonement and holiest day of the year, observed with a 25-hour fast and prayer for atonement, concluding the Ten Days of Repentance.")
    case "Erev Sukkot":
      return String(localized: "Erev Sukkot (14 Tishrei): the eve of Sukkot, when the sukkah is completed and the Four Species are prepared.")
    case "Sukkot":
      return String(localized: "Sukkot (15 Tishrei): the seven-day Feast of Tabernacles. Jews dwell in booths and take up the Four Species, recalling the wilderness journey and the autumn harvest.")
    case "Hoshanah Rabah":
      return String(localized: "Hoshanah Rabah: the seventh day of Sukkot, seen as a final sealing of judgment. It features seven processions with the Four Species and the beating of willow branches.")
    case "Shmini Atzeret":
      return String(localized: "Shmini Atzeret (22 Tishrei): a distinct festival just after Sukkot, including the prayer for rain (Geshem) and, in the Diaspora, Yizkor.")
    case "Simchat Torah":
      return String(localized: "Simchat Torah: the joyous celebration completing and restarting the annual Torah-reading cycle, marked by dancing with the scrolls (hakafot). In Israel it coincides with Shmini Atzeret.")
    case "Erev Hanukah":
      return String(localized: "Erev Hanukah: the eve of Hanukah; the first light is kindled at nightfall on 25 Kislev.")
    case "Hanukah":
      return String(localized: "Hanukah (from 25 Kislev): the eight-day Festival of Lights, commemorating the Maccabees\u{2019} rededication of the Temple and the miracle of the oil. A light is added to the menorah each night.")
    case "Tzom Tevet":
      return String(localized: "Tzom Tevet (10 Tevet): a dawn-to-dusk fast marking the start of the Babylonian siege of Jerusalem that led to the First Temple\u{2019}s destruction.")
    case "Sh. Shirah":
      return String(localized: "Shabbat Shirah: the \u{201C}Sabbath of Song,\u{201D} when the Torah reading includes the Song of the Sea (Exodus 15) sung after the crossing of the Red Sea.")
    case "Tu B'Shvat":
      return String(localized: "Tu BiShvat (15 Shevat): the New Year for Trees, used to reckon the age of fruit trees for tithes. It is marked today by eating fruit and ecological awareness.")
    case "Sh. Shekalim":
      return String(localized: "Shabbat Shekalim: the first of the four special Shabbatot before Pesach, with an added reading recalling the half-shekel given to the Temple.")
    case "Purim Katan":
      return String(localized: "Purim Katan: \u{201C}Minor Purim,\u{201D} on 14 Adar I in a leap year (when Purim itself falls in Adar II). It is a lightly festive day without the Megillah reading.")
    case "Sh. Zachor":
      return String(localized: "Shabbat Zachor: the Shabbat before Purim, with an added reading commanding remembrance of Amalek, ancestor of Haman.")
    case "Ta'anit Ester":
      return String(localized: "Ta\u{2019}anit Esther (usually 13 Adar): a dawn-to-dusk fast on the eve of Purim, recalling the fast Esther proclaimed before approaching the king.")
    case "Erev Purim":
      return String(localized: "Erev Purim: the eve of Purim, when the festival begins at nightfall with the first reading of the Megillah.")
    case "Purim":
      return String(localized: "Purim (14 Adar): celebrates the rescue of the Jews of Persia from Haman\u{2019}s plot, told in the Book of Esther. Customs include reading the Megillah, gifts of food, charity, and a festive meal.")
    case "Shushan Purim":
      return String(localized: "Shushan Purim (15 Adar): observed a day after Purim in cities walled since Joshua\u{2019}s time, such as Jerusalem, recalling the extra day of fighting in Shushan.")
    case "Sh. Parah":
      return String(localized: "Shabbat Parah: one of the four special Shabbatot before Pesach, with an added reading on the Red Heifer (Numbers 19) and ritual purification.")
    default:
      // Any other code is the weekly Torah portion (Parsha) from FindParshaName.
      return String(localized: "Parashat \(name): the weekly Torah portion read on this Shabbat. The Torah is divided into 54 portions read across the year, completed on Simchat Torah.")
    }
  }

  // MARK: - Learn more

  /// A Wikipedia link for the holiday, in the app's current language. Uses
  /// Wikipedia's "go" search so it always resolves (article via title/redirect,
  /// or a search page) — never a dead link, even when titles differ by language.
  static func learnMoreURL(for name: String) -> URL? {
    let lang = (Locale.current.language.languageCode?.identifier == "fr") ? "fr" : "en"
    let query = wikipediaQuery(for: name)
    guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return nil
    }
    return URL(string: "https://\(lang).wikipedia.org/w/index.php?title=Special:Search&search=\(encoded)&go=Go")
  }

  private static func wikipediaQuery(for name: String) -> String {
    if name.hasSuffix("Omer") && name != "Lag BaOmer" { return "Counting of the Omer" }

    switch name {
    case "Pesach", "Erev Pesach":                                    return "Passover"
    case "Chol Hamoed":                                              return "Chol HaMoed"
    case "Sh. HaGadol":                                              return "Shabbat HaGadol"
    case "Sh. HaHodesh", "Sh. Shekalim", "Sh. Zachor", "Sh. Parah":  return "Special Shabbat"
    case "Sh. Hazon":                                                return "Shabbat Hazon"
    case "Sh. Nahamu":                                               return "Shabbat Nachamu"
    case "Sh. Shuvah":                                               return "Shabbat Shuvah"
    case "Sh. Shirah":                                               return "Shabbat Shirah"
    case "Lag BaOmer":                                               return "Lag BaOmer"
    case "Erev Shavuot", "Shavuot":                                  return "Shavuot"
    case "Tzom Tamuz":                                               return "Seventeenth of Tammuz"
    case "Tisha B'Av":                                               return "Tisha B'Av"
    case "S'lichot (evening)":                                       return "Selichot"
    case "Erev R.H.", "Rosh Hashonah":                              return "Rosh Hashanah"
    case "Tzom Gedaliah":                                            return "Fast of Gedalia"
    case "Erev Y.K.", "Yom Kippur":                                 return "Yom Kippur"
    case "Erev Sukkot", "Sukkot":                                   return "Sukkot"
    case "Hoshanah Rabah":                                           return "Hoshana Rabbah"
    case "Shmini Atzeret":                                           return "Shemini Atzeret"
    case "Simchat Torah":                                            return "Simchat Torah"
    case "Erev Hanukah", "Hanukah":                                 return "Hanukkah"
    case "Tzom Tevet":                                               return "Tenth of Tevet"
    case "Tu B'Shvat":                                               return "Tu BiShvat"
    case "Purim Katan":                                              return "Purim Katan"
    case "Ta'anit Ester":                                            return "Fast of Esther"
    case "Erev Purim", "Purim", "Shushan Purim":                    return "Purim"
    case "Yom HaShoah":                                              return "Yom HaShoah"
    case "Yom HaZikaron":                                            return "Yom Hazikaron"
    case "Yom HaAtzmaut":                                            return "Yom Ha'atzmaut"
    case "Yom Yerushalayim":                                         return "Jerusalem Day"
    default:                                                         return "Weekly Torah portion"
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

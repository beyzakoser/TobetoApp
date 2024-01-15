import 'package:flutter/material.dart';
import 'package:flutter_application_1/datas/announcements_dummy_data.dart';
import 'package:flutter_application_1/models/announcements_model.dart';
import 'package:flutter_application_1/widgets/home_page/tabbar_widgets/announcements_widget/announcement_dialog.dart';
import 'package:flutter_application_1/widgets/home_page/tabbar_widgets/lessonsPage_widgets/state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnnouncementItemWidget extends StatefulWidget {
  const AnnouncementItemWidget({super.key});

  @override
  State<AnnouncementItemWidget> createState() => _AnnouncementItemWidgetState();
}

class _AnnouncementItemWidgetState extends State<AnnouncementItemWidget> {
  var filtering;
  void sortAnnouncements(List<AnnouncementModel> list, String sortData) {
    switch (sortData) {
      case "Duyuru":
        setState(() {
          filtering = list.where((element) => element.isAnnouncement).toList();
        });
        break;
      case "Haber":
        setState(() {
          filtering =
              list.where((element) => !(element.isAnnouncement)).toList();
        });
        break;
      case "Invisible": //Okunanlar görünmeyecek
        setState(() {
          filtering = list.where((element) => !(element.isRead)).toList();
        });
      case "Adına göre (Z-A)":
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
      default:
        //"Adına göre alfabetik sırayla (A-Z)"
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  List<AnnouncementModel> filterAnnouncements(
      List<AnnouncementModel> anouncements, String pattern) {
    return anouncements
        .where((element) => element.title.toLowerCase().contains(pattern))
        .toList();
  }

  List<AnnouncementModel> filterTypeAnnouncements(
      List<AnnouncementModel> anouncements) {
    return anouncements.where((element) => element.isAnnouncement).toList();
  }

  @override
  Widget build(BuildContext context) {
    //Textfielda yazılan ile filtreleme kısmı
    filtering = filterAnnouncements(
      announcementsData,
      Provider.of<StateData>(context, listen: true).pattern,
    );

    //Neye göre sıralayacağımı tuttuğum global stateden çektim
    String sortData = Provider.of<StateData>(context, listen: true).sort;

    sortAnnouncements(
        filtering, sortData); //Dropdown menüden seçilene göre sıralama
    return ListView.builder(
        itemCount: filtering.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: Color(0xFF076B34), width: 10)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                filtering[index].isAnnouncement
                                    ? "Duyuru"
                                    : "Haber",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF076B34),
                                    fontWeight: FontWeight.bold)),
                            const Text(
                              "İstanbul Kodluyor",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF076B34),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: SizedBox(
                            child: Text(filtering[index].title,
                                style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.5)),
                                const SizedBox(width: 5),
                                Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(filtering[index].date)
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ))
                              ],
                            ),
                            InkWell(
                              child: Text(
                                "Devamını oku",
                                style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              onTap: () {
                                if (filtering[index].isRead == false) {
                                  //eğer mesaj okunmamış ise tıklandığında bildirimden 1 azalacak
                                  Provider.of<StateData>(context, listen: false)
                                      .countAnnouncement();
                                  filtering[index].isRead = true;
                                }
                                announcementDialogWidget(
                                    context,
                                    filtering[index].title,
                                    filtering[index].text);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

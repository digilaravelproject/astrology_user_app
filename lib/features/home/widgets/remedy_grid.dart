import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:get/get.dart';
import '../../remedy/screens/remedy_detail_screen.dart';

class RemedyGrid extends StatelessWidget {
  const RemedyGrid({Key? key}) : super(key: key);

  // Dummy list of remedies matching the screenshot
  final List<Map<String, dynamic>> remedies = const [
    {
      "planet": "Rahu",
      "image": "https://cdn-icons-png.flaticon.com/512/2917/2917995.png",
      "color": Color(0xFFD32F2F),
      "points": [
        "Ploge thu niy game of the ido oenum.",
        "Welcome o t a nousse Venns",
        "Ploge thogy matteega at at beum"
      ]
    },
    {
      "planet": "Saturn",
      "image": "https://cdn-icons-png.flaticon.com/512/3094/3094651.png",
      "color": Color(0xFF5D4037),
      "points": [
        "Rege you adit th aneae enuh for thorn.",
        "Batu you tu to he poes on the narn beum",
        "Soch a oo mon aloo abeum"
      ]
    },
    {
      "planet": "Ketu",
      "image": "https://cdn-icons-png.flaticon.com/512/2917/2917999.png",
      "color": Color(0xFFE65100),
      "points": [
        "Poge you htu amutoff tang liter anond.",
        "Soot he aa thogp tho youur",
        "Boot ana gouse tha b stars"
      ]
    },
    {
      "planet": "Venus",
      "image": "https://cdn-icons-png.flaticon.com/512/3094/3094673.png",
      "color": Color(0xFFC2185B),
      "points": [
        "Poge thea, uou a ble ooo urthn now ash.",
        "Satn the bena a pace you aaan.",
        "Sato for gouse, thsth beum"
      ]
    },
    {
      "planet": "Ketu",
      "image": "https://cdn-icons-png.flaticon.com/512/2917/2917995.png",
      "color": Color(0xFFFF6347),
      "points": [
        "Poge you to co voese namon wth in you life.",
        "Boot he alhtaar on beum",
        "Both vor gouss it he a beum"
      ]
    },
    {
      "planet": "Sun",
      "image": "https://cdn-icons-png.flaticon.com/512/3094/3094679.png",
      "color": Color(0xFFFF6F00),
      "points": [
        "Poge tho ageo with to gou stal.",
        "Sath fenas ana ll heurn",
        "Plos as gousse the l naquen"
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: remedies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Get.to(() => RemedyDetailScreen(remedy: remedies[index]));
            },
            child: Container(
              width: 200,
              margin: EdgeInsets.only(
                right: index < remedies.length - 1 ? 12 : 0,
              ),
              child: _buildRemedyCard(remedies[index]),
            ),
          );
        },
      ),
    );
  }


  Widget _buildRemedyCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (data['color'] as Color).withOpacity(0.2),
          width: 0.9,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Planet Image and Name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: (data['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Hero(
                    tag: 'remedy_${data['planet']}_${data['image']}',
                    child: Image.network(
                      data['image'] as String,
                      width: 20,
                      height: 20,
                      color: data['color'] as Color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.circle,
                          color: data['color'] as Color,
                          size: 20,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    "${AppStrings.powerfulRemedyFor} ${data['planet']}",
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Remedy Points
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    (data['points'] as List).length > 2 ? 2 : (data['points'] as List).length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.circle,
                                size: 3.5,
                                color: (data['color'] as Color).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: AppText(
                                (data['points'] as List)[index],
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                                height: 1.25,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if ((data['points'] as List).length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.more_horiz,
                            size: 14,
                            color: (data['color'] as Color).withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            AppStrings.viewMore,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: (data['color'] as Color).withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

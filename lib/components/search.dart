import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class SearchBox extends StatefulWidget {
  final void Function()? search;
  final TextEditingController text;

  const SearchBox({
    Key? key,
    required this.search,
    required this.text,
  }) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  UnfocusDisposition disposition = UnfocusDisposition.scope;

  @override
  void initState() {
    super.initState();
    widget.text.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: TextField(
          controller: widget.text,
          onEditingComplete: widget.search,
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            prefixIcon: InkWell(
              onTap: widget.search,
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 22,
              ),
            ),
            suffixIcon: widget.text.text.isNotEmpty
                ? InkWell(
                    onTap: () {
                      widget.text.clear();
                      if (widget.search != null) {
                        widget.search!();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

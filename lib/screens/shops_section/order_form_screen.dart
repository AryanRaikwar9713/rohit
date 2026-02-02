import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/location_api.dart';
import 'package:streamit_laravel/screens/shops_section/model/user_order_history_model.dart';
import '../../components/cached_image_widget.dart';
import '../../local_db.dart';
import 'model/product_list_responce_model.dart';
import 'p/order_api.dart';

const _orderFormGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class OrderFormScreen extends StatefulWidget {
  final Product product;
  final int? variantId;
  final int quantity;

  const OrderFormScreen({
    super.key,
    required this.product,
    this.variantId,
    this.quantity = 1,
  });

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Payment Method
  String _selectedPaymentMethod = 'cash_on_delivery';

  // Use same address checkbox
  bool _useSameAddress = true;

  bool _addNewAddress = false;

  List<IngAddress> _preAddress = [];
  IngAddress? _selectedAddress;

  // Controllers
  final TextEditingController _shippingAmountController =
      TextEditingController(text: '0.00');
  final TextEditingController _taxAmountController =
      TextEditingController(text: '0.00');
  final TextEditingController _discountAmountController =
      TextEditingController(text: '0.00');
  final TextEditingController _customerNoteController = TextEditingController();

  // Shipping Address Controllers
  final TextEditingController _shippingNameController = TextEditingController();
  final TextEditingController _shippingAddressLine1Controller =
      TextEditingController();
  final TextEditingController _shippingAddressLine2Controller =
      TextEditingController();
  final TextEditingController _shippingCityController = TextEditingController();
  final TextEditingController _shippingStateController =
      TextEditingController();
  final TextEditingController _shippingCountryController =
      TextEditingController();
  final TextEditingController _shippingPostalCodeController =
      TextEditingController();
  final TextEditingController _shippingPhoneController =
      TextEditingController();

  // Billing Address Controllers
  final TextEditingController _billingNameController = TextEditingController();
  final TextEditingController _billingAddressLine1Controller =
      TextEditingController();
  final TextEditingController _billingCityController = TextEditingController();
  final TextEditingController _billingStateController = TextEditingController();
  final TextEditingController _billingCountryController =
      TextEditingController();
  final TextEditingController _billingPostalCodeController =
      TextEditingController();

  bool _isSubmitting = false;

  Future<void> _getPreAddress() async {
    _preAddress = await DB().getUserAddress();
    if (_preAddress.isNotEmpty) {
      _selectedAddress = _preAddress.first;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPreAddress();
    _setUserAddress();
  }

  @override
  void dispose() {
    _shippingAmountController.dispose();
    _taxAmountController.dispose();
    _discountAmountController.dispose();
    _customerNoteController.dispose();
    _shippingNameController.dispose();
    _shippingAddressLine1Controller.dispose();
    _shippingAddressLine2Controller.dispose();
    _shippingCityController.dispose();
    _shippingStateController.dispose();
    _shippingCountryController.dispose();
    _shippingPostalCodeController.dispose();
    _shippingPhoneController.dispose();
    _billingNameController.dispose();
    _billingAddressLine1Controller.dispose();
    _billingCityController.dispose();
    _billingStateController.dispose();
    _billingCountryController.dispose();
    _billingPostalCodeController.dispose();
    super.dispose();
  }

  void _copyShippingToBilling() {
    _billingNameController.text = _shippingNameController.text;
    _billingAddressLine1Controller.text = _shippingAddressLine1Controller.text;
    _billingCityController.text = _shippingCityController.text;
    _billingStateController.text = _shippingStateController.text;
    _billingCountryController.text = _shippingCountryController.text;
    _billingPostalCodeController.text = _shippingPostalCodeController.text;
  }

  bool _inProgress = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_useSameAddress) {
      _copyShippingToBilling();
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user data
      final user = await DB().getUser();
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please login to place order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Get shop ID
      final shopId = widget.product.shop?.id;
      if (shopId == null) {
        Get.snackbar(
          'Error',
          'Shop information not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Prepare shipping address
      final shippingAddress = {
        "name": _shippingNameController.text.trim(),
        "address_line_1": _shippingAddressLine1Controller.text.trim(),
        "address_line_2": _shippingAddressLine2Controller.text.trim(),
        "city": _shippingCityController.text.trim(),
        "state": _shippingStateController.text.trim(),
        "country": _shippingCountryController.text.trim(),
        "postal_code": _shippingPostalCodeController.text.trim(),
        "phone": _shippingPhoneController.text.trim(),
      };

      // Prepare billing address
      final billingAddress = {
        "name": _billingNameController.text.trim(),
        "address_line_1": _billingAddressLine1Controller.text.trim(),
        "city": _billingCityController.text.trim(),
        "state": _billingStateController.text.trim(),
        "country": _billingCountryController.text.trim(),
        "postal_code": _billingPostalCodeController.text.trim(),
      };

      // Prepare items
      final items = [
        {
          "product_id": widget.product.id,
          if (widget.variantId != null) "variant_id": widget.variantId,
          "quantity": widget.quantity,
        }
      ];

      // Parse amounts
      final shippingAmount =
          double.tryParse(_shippingAmountController.text.trim()) ?? 0.0;
      final taxAmount =
          double.tryParse(_taxAmountController.text.trim()) ?? 0.0;
      final discountAmount =
          double.tryParse(_discountAmountController.text.trim()) ?? 0.0;

      _inProgress = true;
      // Call API
      await OrderApi().placeOrder(
        shopId: shopId,
        paymentMethod: _selectedPaymentMethod,
        shippingAmount: shippingAmount,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        customerNote: _customerNoteController.text.trim().isNotEmpty
            ? _customerNoteController.text.trim()
            : null,
        shippingAddress: (_selectedAddress == null)
            ? shippingAddress
            : _selectedAddress!.toJson(),
        billingAddress: (_selectedAddress == null)
            ? shippingAddress
            : _selectedAddress!.toJson(),
        items: items,
        onError: (error) {
          Get.snackbar(
            'Error',
            'Failed to place order: $error',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            _isSubmitting = false;
          });
        },
        onFailure: (response) {
          String errorMessage = 'Failed to place order';
          try {
            final body = jsonDecode(response.body);
            errorMessage = body['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Status: ${response.statusCode}';
          }
          Get.snackbar(
            'Error',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            _isSubmitting = false;
          });
        },
        onSuccess: (data) {
          Get.back();
          Get.snackbar(
            'Order Placed',
            'Your order has been placed successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          if (_selectedAddress == null) {
            DB().addNewAddress(IngAddress.fromJson(shippingAddress));
          }
          setState(() {
            _isSubmitting = false;
          });
        },
      );
      _inProgress = false;
    } catch (e) {
      _inProgress = false;
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  _setUserAddress() async {
    var d = await LocationApi().getUserPlacemark();
    setState(() {
      _shippingCityController.text = d?.locality ?? '';
      _shippingStateController.text = d?.administrativeArea ?? '';
      _shippingCountryController.text = d?.country ?? '';
      _shippingPostalCodeController.text = d?.postalCode ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_inProgress) {
          return false;
        }

        return true;
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            title: ShaderMask(
              shaderCallback: (bounds) => _orderFormGradient.createShader(bounds),
              child: Text(
                'Place Order',
                style: boldTextStyle(size: 20, color: Colors.white),
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Summary
                _buildProductSummary(),
                24.height,

                // Payment Method
                _buildSectionTitle('Payment Method'),
                12.height,
                _buildPaymentMethodSelector(),
                24.height,

                // Shipping Address
                _buildSectionTitle('Shipping Address'),
                12.height,
                _buildPreviouseAddress(),
                if (_preAddress.isNotEmpty) 24.height,
                _buildShippingAddressFields(),
                24.height,

                // Billing Address
                // _buildSectionTitle('Billing Address'),
                // 12.height,
                // Row(
                //   children: [
                //     Checkbox(
                //       value: _useSameAddress,
                //       onChanged: (value) {
                //         setState(() {
                //           _useSameAddress = value ?? false;
                //           if (_useSameAddress) {
                //             _copyShippingToBilling();
                //           }
                //         });
                //       },
                //       activeColor: appColorPrimary,
                //     ),
                //     Text(
                //       'Same as shipping address',
                //       style: primaryTextStyle(size: 14, color: Colors.white),
                //     ),
                //   ],
                // ),
                // 12.height,
                // if (!_useSameAddress) ...[
                //   _buildBillingAddressFields(),
                //   24.height,
                // ],

                // Order Details
                _buildSectionTitle('Order Details'),
                12.height,
                _buildOrderDetailsFields(),
                24.height,

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _isSubmitting ? null : _submitOrder,
                      borderRadius: BorderRadius.circular(14),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _isSubmitting ? null : _orderFormGradient,
                          color: _isSubmitting ? Colors.grey[700] : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isSubmitting ? null : [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Place Order',
                                  style: boldTextStyle(size: 17, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                32.height,
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: _orderFormGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.product.featuredImage != null &&
                    widget.product.featuredImage!.isNotEmpty
                ? CachedImageWidget(
                    url: widget.product.featuredImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
          ),
                16.width,
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name ?? 'Product',
                        style: boldTextStyle(size: 16, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.height,
                      if (widget.product.price != null)
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              _orderFormGradient.createShader(bounds),
                          child: Text(
                            '${widget.product.price!.toStringAsFixed(2)} Bolts',
                            style: boldTextStyle(size: 18, color: Colors.white),
                          ),
                        ),
                      8.height,
                      Text(
                        'Quantity: ${widget.quantity}',
                        style: secondaryTextStyle(size: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: _orderFormGradient,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withOpacity(0.3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        12.width,
        ShaderMask(
          shaderCallback: (bounds) => _orderFormGradient.createShader(bounds),
          child: Text(
            title,
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2E)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: _orderFormGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                _buildRadioTile('cash_on_delivery', 'Cash on Delivery', Icons.money_rounded),
                12.height,
                _buildRadioTile('wallet', 'Wallet', Icons.account_balance_wallet_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String value, String title, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            onChanged: (val) {
              setState(() {
                _selectedPaymentMethod = val!;
              });
            },
            activeColor: const Color(0xFFFF9800),
          ),
          ShaderMask(
            shaderCallback: (bounds) => _orderFormGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          12.width,
          Text(
            title,
            style: primaryTextStyle(size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressFields() {
    if (_selectedAddress != null) {
      return SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2E)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: _orderFormGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
          _buildTextField(
            controller: _shippingNameController,
            label: 'Full Name *',
            onChanged: (d) {
              if (_selectedAddress != null) {
                _selectedAddress = null;
                setState(() {});
              }
            },
            hint: 'Enter full name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          ),
          16.height,
          _buildTextField(
            controller: _shippingAddressLine1Controller,
            onChanged: (d) {
              if (_selectedAddress != null) {
                _selectedAddress = null;
                setState(() {});
              }
            },
            label: 'Address Line 1 *',
            hint: 'Enter address',
            icon: Icons.home,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),
          16.height,
          _buildTextField(
            controller: _shippingAddressLine2Controller,
            onChanged: (d) {
              if (_selectedAddress != null) {
                _selectedAddress = null;
                setState(() {});
              }
            },
            label: 'Address Line 2 (Optional)',
            hint: 'Apartment, suite, etc.',
            icon: Icons.home_work,
            maxLines: 2,
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  onChanged: (d) {
                    if (_selectedAddress != null) {
                      _selectedAddress = null;
                      setState(() {});
                    }
                  },
                  controller: _shippingCityController,
                  label: 'City *',
                  hint: 'Enter city',
                  icon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              16.width,
              Expanded(
                child: _buildTextField(
                  onChanged: (d) {
                    if (_selectedAddress != null) {
                      _selectedAddress = null;
                      setState(() {});
                    }
                  },
                  controller: _shippingStateController,
                  label: 'State *',
                  hint: 'Enter state',
                  icon: Icons.map,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  onChanged: (d) {
                    if (_selectedAddress != null) {
                      _selectedAddress = null;
                      setState(() {});
                    }
                  },
                  controller: _shippingCountryController,
                  label: 'Country *',
                  hint: 'Enter country',
                  icon: Icons.public,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
              ),
              16.width,
              Expanded(
                child: _buildTextField(
                  onChanged: (d) {
                    if (_selectedAddress != null) {
                      _selectedAddress = null;
                      setState(() {});
                    }
                  },
                  controller: _shippingPostalCodeController,
                  label: 'Postal Code *',
                  hint: 'Enter postal code',
                  icon: Icons.markunread_mailbox,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter postal code';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          16.height,
          _buildTextField(
            onChanged: (d) {
              if (_selectedAddress != null) {
                _selectedAddress = null;
                setState(() {});
              }
            },
            controller: _shippingPhoneController,
            label: 'Phone Number *',
            hint: 'Enter phone number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviouseAddress() {
    if (_preAddress.isEmpty) {
      return SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          if (kDebugMode)
            Text(
              '${_selectedAddress?.toJson()}',
              style: TextStyle(color: Colors.white),
            ),
          for (var d in _preAddress)
            GestureDetector(
              onTap: () {
                _selectedAddress = d;
                setState(() {});
              },
              child: RadioListTile(
                value: d.toJson().toString(),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: Text(
                  "${d.name}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${d.addressLine1} ${d.addressLine2} ${d.city} ${d.state} ${d.country}\nPincode :- ${d.postalCode}\nPhone No :- ${d.phone}",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                groupValue: _selectedAddress?.toJson().toString(),
              ),
            ),
          if (_selectedAddress != null)
            Container(
              width: double.infinity,
              margin: EdgeInsetsGeometry.symmetric(vertical: 5),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedAddress != null) {
                      _selectedAddress = null;
                      setState(() {});
                    }
                  },
                  child: Text(
                    'Add New Address',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
            ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressFields() {
    if (_selectedAddress != null) {
      return SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _billingNameController,
            label: 'Full Name *',
            hint: 'Enter full name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          ),
          16.height,
          _buildTextField(
            controller: _billingAddressLine1Controller,
            label: 'Address Line 1 *',
            hint: 'Enter address',
            icon: Icons.home,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _billingCityController,
                  label: 'City *',
                  hint: 'Enter city',
                  icon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              16.width,
              Expanded(
                child: _buildTextField(
                  controller: _billingStateController,
                  label: 'State *',
                  hint: 'Enter state',
                  icon: Icons.map,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _billingCountryController,
                  label: 'Country *',
                  hint: 'Enter country',
                  icon: Icons.public,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
              ),
              16.width,
              Expanded(
                child: _buildTextField(
                  controller: _billingPostalCodeController,
                  label: 'Postal Code *',
                  hint: 'Enter postal code',
                  icon: Icons.markunread_mailbox,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter postal code';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsFields() {
    return Column(
      children: [
        // _buildTextField(
        //   controller: _shippingAmountController,
        //   label: 'Shipping Amount',
        //   hint: '0.00',
        //   icon: Icons.local_shipping,
        //   keyboardType: TextInputType.numberWithOptions(decimal: true),
        // ),
        // 16.height,
        // _buildTextField(
        //   controller: _taxAmountController,
        //   label: 'Tax Amount',
        //   hint: '0.00',
        //   icon: Icons.receipt,
        //   keyboardType: TextInputType.numberWithOptions(decimal: true),
        // ),
        // 16.height,
        // _buildTextField(
        //   controller: _discountAmountController,
        //   label: 'Discount Amount',
        //   hint: '0.00',
        //   icon: Icons.discount,
        //   keyboardType: TextInputType.numberWithOptions(decimal: true),
        // ),
        // 16.height,
        _buildTextField(
          controller: _customerNoteController,
          label: 'Customer Note (Optional)',
          hint: 'Any special instructions...',
          icon: Icons.note,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Function(String)? onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: primaryTextStyle(size: 14, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: secondaryTextStyle(size: 12, color: Colors.grey[400]),
        hintStyle: secondaryTextStyle(size: 14, color: Colors.grey[600]),
        prefixIcon: ShaderMask(
          shaderCallback: (bounds) => _orderFormGradient.createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF2E2E2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFF161616),
      ),
    );
  }
}

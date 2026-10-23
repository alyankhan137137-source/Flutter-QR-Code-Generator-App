import 'package:flutter/material.dart';

class TemplatesScreen extends StatefulWidget {
  final Function(String data, String title, String type) onSelectTemplate;

  const TemplatesScreen({super.key, required this.onSelectTemplate});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  int _selectedCategory = 0;

  final List<String> _categories = ['WiFi', 'vCard', 'Email', 'SMS', 'Phone'];

  // WiFi Controllers
  final _wifiSsidController = TextEditingController();
  final _wifiPassController = TextEditingController();
  String _wifiEncryption = 'WPA';

  // vCard Controllers
  final _vNameController = TextEditingController();
  final _vPhoneController = TextEditingController();
  final _vEmailController = TextEditingController();
  final _vOrgController = TextEditingController();
  final _vWebController = TextEditingController();

  // Email Controllers
  final _emailToController = TextEditingController();
  final _emailSubController = TextEditingController();
  final _emailBodyController = TextEditingController();

  // SMS Controllers
  final _smsPhoneController = TextEditingController();
  final _smsMsgController = TextEditingController();

  // Phone Controller
  final _phoneNumController = TextEditingController();

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPassController.dispose();
    _vNameController.dispose();
    _vPhoneController.dispose();
    _vEmailController.dispose();
    _vOrgController.dispose();
    _vWebController.dispose();
    _emailToController.dispose();
    _emailSubController.dispose();
    _emailBodyController.dispose();
    _smsPhoneController.dispose();
    _smsMsgController.dispose();
    _phoneNumController.dispose();
    super.dispose();
  }

  void _generateAndApply() {
    String data = '';
    String title = '';
    String type = '';

    switch (_selectedCategory) {
      case 0: // WiFi
        final ssid = _wifiSsidController.text.trim();
        final pass = _wifiPassController.text.trim();
        if (ssid.isEmpty) {
          _showError('Please enter WiFi Network Name (SSID)');
          return;
        }
        data = 'WIFI:S:$ssid;T:$_wifiEncryption;P:$pass;;';
        title = 'WiFi: $ssid';
        type = 'wifi';
        break;

      case 1: // vCard
        final name = _vNameController.text.trim();
        final phone = _vPhoneController.text.trim();
        final email = _vEmailController.text.trim();
        final org = _vOrgController.text.trim();
        final web = _vWebController.text.trim();
        if (name.isEmpty) {
          _showError('Please enter Full Name');
          return;
        }
        data = 'BEGIN:VCARD\nVERSION:3.0\nN:$name\nFN:$name\nORG:$org\nTEL:$phone\nEMAIL:$email\nURL:$web\nEND:VCARD';
        title = 'Contact: $name';
        type = 'vcard';
        break;

      case 2: // Email
        final to = _emailToController.text.trim();
        final sub = _emailSubController.text.trim();
        final body = _emailBodyController.text.trim();
        if (to.isEmpty) {
          _showError('Please enter recipient email');
          return;
        }
        data = 'mailto:$to?subject=${Uri.encodeComponent(sub)}&body=${Uri.encodeComponent(body)}';
        title = 'Email: $to';
        type = 'email';
        break;

      case 3: // SMS
        final phone = _smsPhoneController.text.trim();
        final msg = _smsMsgController.text.trim();
        if (phone.isEmpty) {
          _showError('Please enter phone number');
          return;
        }
        data = 'SMSTO:$phone:$msg';
        title = 'SMS: $phone';
        type = 'sms';
        break;

      case 4: // Phone
        final phone = _phoneNumController.text.trim();
        if (phone.isEmpty) {
          _showError('Please enter phone number');
          return;
        }
        data = 'tel:$phone';
        title = 'Call: $phone';
        type = 'phone';
        break;
    }

    widget.onSelectTemplate(data, title, type);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template applied successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Templates'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category selector chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = index;
                      });
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Configure ${_categories[_selectedCategory]} QR',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSelectedForm(),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _generateAndApply,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Generate from Template'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedForm() {
    switch (_selectedCategory) {
      case 0:
        return Column(
          children: [
            TextField(
              controller: _wifiSsidController,
              decoration: InputDecoration(
                labelText: 'Network Name (SSID)',
                prefixIcon: const Icon(Icons.wifi),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wifiPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _wifiEncryption,
              decoration: InputDecoration(
                labelText: 'Encryption Type',
                prefixIcon: const Icon(Icons.security),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['WPA', 'WEP', 'nopass']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _wifiEncryption = val);
              },
            ),
          ],
        );

      case 1:
        return Column(
          children: [
            TextField(
              controller: _vNameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vOrgController,
              decoration: InputDecoration(
                labelText: 'Organization',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vWebController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Website URL',
                prefixIcon: const Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          children: [
            TextField(
              controller: _emailToController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Recipient Email *',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailSubController,
              decoration: InputDecoration(
                labelText: 'Subject',
                prefixIcon: const Icon(Icons.subject),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailBodyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message Body',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );

      case 3:
        return Column(
          children: [
            TextField(
              controller: _smsPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smsMsgController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'SMS Message',
                prefixIcon: const Icon(Icons.sms),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );

      case 4:
        return Column(
          children: [
            TextField(
              controller: _phoneNumController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

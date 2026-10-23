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
        content: Text('Template loaded into Generator!'),
        backgroundColor: Colors.green,
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
                      fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Configure ${_categories[_selectedCategory]} QR',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSelectedForm(),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generateAndApply,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Generate QR Code from Template'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
              decoration: const InputDecoration(
                labelText: 'Network Name (SSID)',
                prefixIcon: Icon(Icons.wifi),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wifiPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _wifiEncryption,
              decoration: const InputDecoration(
                labelText: 'Encryption Type',
                prefixIcon: Icon(Icons.security),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vOrgController,
              decoration: const InputDecoration(
                labelText: 'Organization / Company',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vWebController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Recipient Email *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailSubController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailBodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                prefixIcon: Icon(Icons.message),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smsMsgController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'SMS Message',
                prefixIcon: Icon(Icons.sms),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// Constantes do app. Mudar um limite aqui muda o comportamento em todo o app.

// Senha (RF01)
const int minPasswordLength = 8;

// Status de validade (RN01): dias restantes até vencer.
const int criticalMaxDays = 2; // 0..2 dias -> critical
const int warningMaxDays = 5; // 3..5 dias -> warning; acima disso -> ok

// Código de convite da casa (RN03): 6 caracteres, sem 0/O e 1/I (ambíguos).
const int inviteCodeLength = 6;
const String inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

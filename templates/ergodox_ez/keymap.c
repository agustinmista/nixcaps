/* Copyright 2020 ZSA Technology Labs, Inc <@zsa>
 * Copyright 2020 Jack Humbert <jack.humb@gmail.com>
 * Copyright 2020 Christopher Courtney, aka Drashna Jael're  (@drashna) <drashna@live.com>
 * Copyright 2023 Agustín Mista <agustin@mista.me>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include QMK_KEYBOARD_H
#include "version.h"

/*
 * Layers
 */

enum keyboard_layers {
  BASE_LAYER,
  LOWER_LAYER,
  RAISE_LAYER,
  HYPER_LAYER
};

/*
 * Custom keycodes
 */

enum keyboard_keycodes {
  BASE = SAFE_RANGE,    // Set the default layer to BASE_LAYER
  LOWER,                // Set the default layer to LOWER_LAYER
  RAISE,                // Set the default layer to RAISE_LAYER
  HYPER                 // Set the default layer to HYPER_LAYER
};

/*
 * Keycode aliases
 */

// Aliases for LT() to a particular layer
#define LT_BASE(kc)  LT(BASE_LAYER,kc)
#define LT_LOWER(kc) LT(LOWER_LAYER,kc)
#define LT_RAISE(kc) LT(RAISE_LAYER,kc)
#define LT_HYPER(kc) LT(HYPER_LAYER,kc)

// Aliases for home row modifiers
#define HR_A    LCTL_T(KC_A)
#define HR_S    LSFT_T(KC_S)
#define HR_D    LALT_T(KC_D)
#define HR_F    LGUI_T(KC_F)

#define HR_J    LGUI_T(KC_J)
#define HR_K    LALT_T(KC_K)
#define HR_L    LSFT_T(KC_L)
#define HR_SCLN LCTL_T(KC_SCLN)

// Aliases for other combos
#define CTL_PUP LCTL(KC_PGUP)
#define CTL_PDN LCTL(KC_PGDN)
#define GUI_TAB LGUI(KC_TAB)

// Aliases for MEH
#define MEH_F1  MEH(KC_F1)
#define MEH_F2  MEH(KC_F2)
#define MEH_F3  MEH(KC_F3)
#define MEH_F4  MEH(KC_F4)
#define MEH_F5  MEH(KC_F5)
#define MEH_F6  MEH(KC_F6)
#define MEH_F7  MEH(KC_F7)
#define MEH_F8  MEH(KC_F8)
#define MEH_F9  MEH(KC_F9)
#define MEH_F10 MEH(KC_F10)
#define MEH_F11 MEH(KC_F11)
#define MEH_F12 MEH(KC_F12)

/*
 * Initialization code
 */

void keyboard_post_init_user(void) {
  ergodox_led_all_off();
}

/*
 * Led helpers
 */

// Change the top right RGB to indicate the layer
void ergodox_led_set_color_by_layer(uint8_t layer) {
  ergodox_led_all_off();
  switch(layer) {
    case BASE_LAYER:
      break;
    case LOWER_LAYER:
      ergodox_right_led_1_on();
      break;
    case RAISE_LAYER:
      ergodox_right_led_2_on();
      break;
    case HYPER_LAYER:
      ergodox_right_led_3_on();
      break;
  }
}

// Blink the right LED 1
void ergodox_blink_right_led_1(uint8_t times) {
  for (int i=0; i<times; i++) {
    ergodox_right_led_1_on();
    _delay_ms(50);
    ergodox_right_led_1_off();
    _delay_ms(50);
  }
}

// Blink the right LED 2
void ergodox_blink_right_led_2(uint8_t times) {
  for (int i=0; i<times; i++) {
    ergodox_right_led_2_on();
    _delay_ms(50);
    ergodox_right_led_2_off();
    _delay_ms(50);
  }
}

// Blink the right LED 3
void ergodox_blink_right_led_3(uint8_t times) {
  for (int i=0; i<times; i++) {
    ergodox_right_led_2_on();
    _delay_ms(50);
    ergodox_right_led_2_off();
    _delay_ms(50);
  }
}

/*
 * Leader mode
 */

bool leader_mode = false;

// Macros to trigger standard compose key sequences
#define COMPOSE_KEY      SS_TAP(X_RALT)
#define LOWER_ACUTE(kc)  SS_TAP(X_QUOT) SS_TAP(kc)
#define UPPER_ACUTE(kc)  SS_TAP(X_QUOT) SS_LSFT(SS_TAP(kc))
#define LOWER_UMLAUT(kc) SS_LSFT(SS_TAP(X_QUOT)) SS_TAP(kc)
#define UPPER_UMLAUT(kc) SS_LSFT(SS_TAP(X_QUOT)) SS_LSFT(SS_TAP(kc))

// Macros for registering key sequences
#define ONE_KEY_SEQUENCE(kc1, str) \
  if (leader_sequence_one_key(kc1)) { SEND_STRING(str); return true; }
#define TWO_KEYS_SEQUENCE(kc1, kc2, str) \
  if (leader_sequence_two_keys(kc1, kc2)) { SEND_STRING(str); return true; }
#define THREE_KEYS_SEQUENCE(kc1, kc2, kc3, str) \
  if (leader_sequence_three_keys(kc1, kc2, kc3)) { SEND_STRING(str); return true; }

// The dictionary of sequences
bool process_leader_sequence(void) {
  // leader + t ==> Ctrl+Shift+t
  ONE_KEY_SEQUENCE(KC_T, SS_LCTL(SS_LSFT(SS_TAP(X_T))));
  // leader + q ==> Alt+F4
  ONE_KEY_SEQUENCE(KC_Q, SS_LALT(SS_TAP(X_F4)));
  // leader + s + s ==> Sleep
  TWO_KEYS_SEQUENCE(KC_S, KC_S, SS_TAP(X_PWR));
  // Lowercase acutes
  // E.g. leader + a ==> Right Alt+'+a ==> á
  ONE_KEY_SEQUENCE(KC_A, COMPOSE_KEY LOWER_ACUTE(X_A));
  ONE_KEY_SEQUENCE(KC_E, COMPOSE_KEY LOWER_ACUTE(X_E));
  ONE_KEY_SEQUENCE(KC_I, COMPOSE_KEY LOWER_ACUTE(X_I));
  ONE_KEY_SEQUENCE(KC_O, COMPOSE_KEY LOWER_ACUTE(X_O));
  ONE_KEY_SEQUENCE(KC_U, COMPOSE_KEY LOWER_ACUTE(X_U));
  // Uppercase acutes
  // E.g. leader + Left Shift + a ==> Right Alt+'+A ==> Á
  TWO_KEYS_SEQUENCE(KC_LSFT, KC_A, COMPOSE_KEY UPPER_ACUTE(X_A));
  TWO_KEYS_SEQUENCE(KC_LSFT, KC_E, COMPOSE_KEY UPPER_ACUTE(X_E));
  TWO_KEYS_SEQUENCE(KC_LSFT, KC_I, COMPOSE_KEY UPPER_ACUTE(X_I));
  TWO_KEYS_SEQUENCE(KC_LSFT, KC_O, COMPOSE_KEY UPPER_ACUTE(X_O));
  TWO_KEYS_SEQUENCE(KC_LSFT, KC_U, COMPOSE_KEY UPPER_ACUTE(X_U));
  // Ñ letter
  ONE_KEY_SEQUENCE(KC_N, COMPOSE_KEY SS_LSFT(SS_TAP(X_GRAVE)) SS_TAP(X_N));
  TWO_KEYS_SEQUENCE(KC_LSFT, KC_N, COMPOSE_KEY SS_LSFT(SS_TAP(X_GRAVE)) SS_LSFT(SS_TAP(X_N)));
  // Swedish letters
  TWO_KEYS_SEQUENCE(KC_A, KC_E, COMPOSE_KEY LOWER_UMLAUT(X_A));
  TWO_KEYS_SEQUENCE(KC_O, KC_E, COMPOSE_KEY LOWER_UMLAUT(X_O));
  TWO_KEYS_SEQUENCE(KC_O, KC_A, COMPOSE_KEY SS_TAP(X_O) SS_TAP(X_A))
  THREE_KEYS_SEQUENCE(KC_LSFT, KC_A, KC_E, COMPOSE_KEY UPPER_UMLAUT(X_A));
  THREE_KEYS_SEQUENCE(KC_LSFT, KC_O, KC_E, COMPOSE_KEY UPPER_UMLAUT(X_O));
  THREE_KEYS_SEQUENCE(KC_LSFT, KC_O, KC_A, COMPOSE_KEY SS_TAP(X_O) SS_LSFT(SS_TAP(X_A)));

  return false;
}

// Start leader mode hook
void leader_start_user(void) {
  ergodox_led_all_on();
  leader_mode = true;
}

// End leader mode hook
void leader_end_user(void) {
  bool success = process_leader_sequence();
  ergodox_led_all_off();
  if (success) {
    ergodox_blink_right_led_2(2);
  } else {
    ergodox_blink_right_led_1(2);
  }
  leader_mode = false;
}

/*
 * Sticky layers
 */

uint16_t sticky_layer = BASE_LAYER;

// Set a given layer or revert to the base one if the given layer is already set
void set_or_revert_default_layer(uint16_t layer) {
  if (sticky_layer == layer) { // The layer is already set, move to the base layer
    sticky_layer = BASE_LAYER;
    set_single_default_layer(BASE_LAYER);
    ergodox_led_set_color_by_layer(BASE_LAYER);
  } else { // The layer is not set, move to it
    sticky_layer = layer;
    set_single_default_layer(layer);
  }
}

/*
 * Process custom keycodes
 */

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    // Sticky mode keycodes
    case LOWER:
      if (record->event.pressed) {
        set_or_revert_default_layer(LOWER_LAYER);
      }
      return false;
    case RAISE:
      if (record->event.pressed) {
        set_or_revert_default_layer(RAISE_LAYER);
      }
      return false;
    case HYPER:
      if (record->event.pressed) {
        set_or_revert_default_layer(HYPER_LAYER);
      }
      return false;
  }

  return true;
};

/*
 * Change the top right LEDs based on layer
 */

layer_state_t layer_state_set_user(layer_state_t state) {

  // Do not repaint if we are in a mode that overrides the default layer color
  if (leader_mode) {
    return state;
  }

  // Set the underglow to the corresponding layer color
  switch (get_highest_layer(state | default_layer_state)) {
    case LOWER_LAYER:
      ergodox_led_set_color_by_layer(LOWER_LAYER);
      break;
    case RAISE_LAYER:
      ergodox_led_set_color_by_layer(RAISE_LAYER);
      break;
    case HYPER_LAYER:
      ergodox_led_set_color_by_layer(HYPER_LAYER);
      break;
    default:
      ergodox_led_all_off();
      break;
  }

  return state;
}

/*
 * Keymaps
 */

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

[BASE_LAYER] = LAYOUT_ergodox(
  // Left hand
  KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    _______,
  KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    _______,
  KC_ESC,  HR_A,    HR_S,    HR_D,    HR_F,    KC_G,
  KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    _______,
  MEH_F1,  MEH_F2,  MEH_F3,  MEH_F4,  KC_LCBR,
                                               KC_VOLD, KC_VOLU,
                                                        KC_MUTE,
                             LT_LOWER(KC_SPC), KC_LGUI, QK_LEAD,

  // Right hand
  _______, KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_BSPC,
  _______, KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
           KC_H,    HR_J,    HR_K,    HR_L,    HR_SCLN, KC_QUOT,
  _______, KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_RSFT,
                    KC_RCBR, MEH_F5,  MEH_F6,  MEH_F7,  MEH_F8,
  KC_MPRV, KC_MNXT,
  KC_MPLY,
  QK_LEAD, KC_BSPC, LT_RAISE(KC_ENT)
),

[LOWER_LAYER] = LAYOUT_ergodox(
  // Left hand
  KC_TILD, KC_EXLM, KC_AT,   KC_HASH, KC_DLR,  KC_PERC, _______,
  GUI_TAB, KC_F1,   KC_F2,   KC_F3,   KC_F4,   _______, _______,
  _______, KC_F5,   KC_F6,   KC_F7,   KC_F8,   _______,
  _______, KC_F9,   KC_F10,  KC_F11,  KC_F12,  _______, _______,
  _______, _______, _______, _______, KC_LBRC,
                                               _______, _______,
                                                        _______,
                                      _______, _______, LOWER,

  // Right hand
  _______, KC_CIRC, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN, KC_DEL,
  _______, _______, KC_UNDS, KC_PLUS, _______, _______, KC_PIPE,
           _______, KC_MINS, KC_EQL,  _______, KC_COLN, KC_DQUO,
  _______, _______, _______, KC_LABK, KC_RABK, KC_QUES, _______,
                    KC_RBRC, _______, _______, _______, _______,
  _______, _______,
  _______,
  LOWER,   KC_DEL,  LT_HYPER(KC_ENT)
),

[RAISE_LAYER] = LAYOUT_ergodox(
  // Left hand
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, MS_BTN2, MS_UP,   MS_BTN1, _______, _______,
  _______, _______, MS_LEFT, MS_DOWN, MS_RGHT, _______,
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, KC_LBRC,
                                               _______, _______,
                                                        _______,
                             LT_HYPER(KC_SPC), _______, RAISE,

  // Right hand
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, CTL_PUP, KC_UP,   CTL_PDN, _______, _______,
           _______, KC_LEFT, KC_DOWN, KC_RGHT, _______, _______,
  _______, _______, _______, _______, _______, _______, _______,
                    KC_RBRC, _______, _______, _______, _______,
  _______, _______,
  _______,
  RAISE,   _______, _______
),

[HYPER_LAYER] = LAYOUT_ergodox(
  // Left hand
  _______, _______, _______, _______, _______, _______, _______,
  _______, KC_F13,  KC_F14,  KC_F15,  KC_F16,  _______, _______,
  _______, KC_F17,  KC_F18,  KC_F19,  KC_F20,  _______,
  _______, KC_F21,  KC_F22,  KC_F23,  KC_F24,  _______, _______,
  _______, _______, _______, _______, KC_LABK,
                                               _______, _______,
                                                        _______,
                                      _______, _______, HYPER,

  // Right hand
  _______, _______, _______, _______, _______, _______, QK_BOOT,
  _______, _______, _______, _______, _______, _______, _______,
           _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______, _______, _______,
                    KC_RABK, _______, _______, _______, _______,
  _______, _______,
  _______,
  HYPER,   _______, _______
)};

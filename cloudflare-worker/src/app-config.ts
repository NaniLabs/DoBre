export interface AppConfig {
  version: string;
  lastUpdate: string | null;
  message: string | null;
  maintenanceMode: boolean;
  minimumSupportedVersion: string;
  publicationTypes: PublicationType[];
  tariffs: Tariffs;
  percentages: Percentages;
  fixedCharges: FixedCharge[];
  shipping: ShippingConfig;
  installments: InstallmentConfig;
  categories: Category[];
  advancedMode: AdvancedModeConfig;
  input: InputConfig;
}

export interface PublicationType {
  id: string;
  name: string;
}

export interface Tariffs {
  sellerFeeRate: number;
  unitCostBelowThreshold: number;
}

export interface Percentages {
  sellerFeeRate: number;
}

export interface FixedCharge {
  maxPrice: number | null;
  charge: number;
}

export interface ShippingConfig {
  freeShippingThreshold: number;
  weightTable: ShippingWeightTier[];
}

export interface ShippingWeightTier {
  maxWeight: number;
  below33000: number;
  between33000And49999: number;
  above50000: number;
}

export interface InstallmentConfig {
  defaultOptionId: string;
  options: InstallmentOption[];
}

export interface InstallmentOption {
  id: string;
  label: string;
  rate: number;
}

export interface Category {
  id: string;
  name: string;
  fees: CategoryFees;
}

export interface CategoryFees {
  classic: number;
  premium: number;
}

export interface AdvancedModeConfig {
  enabledByDefault: boolean;
  parameters: AdvancedModeParameters;
}

export interface AdvancedModeParameters {
  notes: string;
}

export interface InputConfig {
  minAllowedPrice: number;
  maxAllowedPrice: number;
}
